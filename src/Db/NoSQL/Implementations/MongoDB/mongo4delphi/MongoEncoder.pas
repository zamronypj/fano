{***************************************************************************}
{                                                                           }
{                    Mongo Delphi Driver                                    }
{                                                                           }
{           Copyright (c) 2012 Fabricio Colombo                             }
{                                                                           }
{  Licensed under the Apache License, Version 2.0 (the "License");          }
{  you may not use this file except in compliance with the License.         }
{  You may obtain a copy of the License at                                  }
{                                                                           }
{      http://www.apache.org/licenses/LICENSE-2.0                           }
{                                                                           }
{  Unless required by applicable law or agreed to in writing, software      }
{  distributed under the License is distributed on an "AS IS" BASIS,        }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{  See the License for the specific language governing permissions and      }
{  limitations under the License.                                           }
{                                                                           }
{***************************************************************************}
unit MongoEncoder;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses BSONStream, BSONTypes;

type
  IMongoEncoder = interface
    ['{F6711577-18CC-4E99-88AA-8B0E8E78C9B2}']
    procedure SetBuffer(ABuffer: TBSONStream);
    procedure Encode(const ABSONObject: IBSONBasicObject);
  end;

  TDefaultMongoEncoder = class(TInterfacedObject, IMongoEncoder)
  private
    FBuffer: TBSONStream;

    procedure put(AType: Byte; AName: String);overload;
    function put(AValue: String): Integer;overload;
    procedure putValueString(AValue: String);
    procedure putNull(AName: String);
    procedure putDate(AName: String; AValue: TDateTime);
    procedure putInt(AName: String; AValue: LongWord);
    procedure putInt64(AName: String; AValue: Int64);
    procedure putFloat(AName: String; AValue: Extended);
    procedure putString(AName: String; AValue: String; AType: Integer);
    procedure putBoolean(AName: String; AValue: Boolean);
    procedure putObjectId(AName: String; const AValue: IBSONObjectId);
    procedure putUUID(AName: String; AValue: TGUID);
    procedure putBinary(name: String; const val: IBSONBinary);
    procedure putRegEx(name: String; const val: IBSONRegEx);
    procedure putCodeWScope(name: String; const val: IBSONCode_W_Scope);
    procedure putTimeStamp(name: String; const val: IBSONTimeStamp);
    procedure putDBRef(name: String; const val: IBSONDBRef);
    procedure putObject(name: String; const val: IBSONObject);

    procedure PutObjectField(const AItem: TBSONItem);
    procedure PutInterfaceField(name: String; const val: IUnknown);
  public
    procedure SetBuffer(ABuffer: TBSONStream);
    procedure Encode(const ABSONObject: IBSONBasicObject);
  end;

  TMongoEncoderFactory = class
  public
    class function DefaultEncoder(): IMongoEncoder;
  end;

implementation

uses DateUtils, SysUtils, Variants, BSON, MongoException, Classes, 
  MongoUtils, Windows;

{ TDefaultMongoEncoder }

procedure TDefaultMongoEncoder.put(AType: Byte; AName: String);
begin
  FBuffer.WriteByte(AType);
  put(AName);
end;

function TDefaultMongoEncoder.put(AValue: String): Integer;
begin
  Result := FBuffer.WriteUTF8String(AValue);  
end;

procedure TDefaultMongoEncoder.putBoolean(AName: String; AValue: Boolean);
begin
  put(BSON_BOOLEAN, AName);

  if AValue then
    FBuffer.WriteByte(BSON_BOOL_TRUE)
  else
    FBuffer.WriteByte(BSON_BOOL_FALSE);
end;

procedure TDefaultMongoEncoder.putDate(AName: String; AValue: TDateTime);
var
  vUTCDate: Int64;
begin
  put(BSON_DATETIME, AName);

  vUTCDate := Round((AValue - UnixDateDelta) * MSecsPerDay);

  FBuffer.WriteInt64(vUTCDate);
end;

procedure TDefaultMongoEncoder.putFloat(AName: String; AValue: Extended);
begin
  put(BSON_FLOAT, AName);
  FBuffer.writeDouble(AValue);
end;

procedure TDefaultMongoEncoder.putInt(AName: String; AValue: LongWord);
begin
  put(BSON_INT32, AName);
  FBuffer.writeInt(AValue);
end;

procedure TDefaultMongoEncoder.putInt64(AName: String; AValue: Int64);
begin
  put(BSON_INT64, AName);
  FBuffer.WriteInt64(AValue);
end;

procedure TDefaultMongoEncoder.putNull(AName: String);
begin
  put(BSON_NULL, AName);
end;

procedure TDefaultMongoEncoder.PutObjectField(const AItem: TBSONItem);
var
  vGUID: TGUID;
  name,
  value: String;
begin
  name := AItem.Name;

  if SameText(name, '_transientFields') then Exit;

  if SameText(name, '$where') and (AItem.ValueType = bvtString) then
  begin
    putString(name, AItem.AsString, BSON_CODE);
    Exit;
  end;

  case AItem.ValueType of
    bvtNull: putNull(name);
    bvtBoolean: putBoolean(name, AItem.AsBoolean);
    bvtInteger: putInt(name, AItem.AsInteger);
    bvtInt64: putInt64(name, AItem.AsInt64);
    bvtDouble: putFloat(name, AItem.AsFloat);
    bvtDateTime: putDate( name , AItem.AsDateTime);
    bvtString:  begin
                  value := AItem.AsString;

                  if TGUIDUtils.TryStringToGuid(value, vGUID) then
                    putUUID(name, vGUID)
                  else if (AItem.IsMinKey) then
                    put(BSON_MINKEY, name)
                  else if (AItem.IsMaxKey) then
                    put(BSON_MAXKEY, name)
                  else if (name = KEY_ID) then
                    putObjectId(name, TBSONObjectId.NewFromOID(value))
                  else
                    putString(name, value, BSON_STRING);
                end;
    bvtInterface: PutInterfaceField(name, IUnknown(AItem.Value));

//  else if (val instanceof DBRefBase)
//      BSONObject temp = new BasicBSONObject();
//      temp.put("$ref", ((DBRefBase)val).getRef());
//      temp.put("$id", ((DBRefBase)val).getId());
//      putObject( name, temp );
//  else if ( val instanceof MinKey )
//      putMinKey( name );
//  else if ( val instanceof MaxKey )
//      putMaxKey( name );
  else
    raise EIllegalArgumentException.CreateResFmt(@sInvalidVariantValueType, [AItem.GetValueTypeDesc]);
  end;
end;

procedure TDefaultMongoEncoder.putString(AName, AValue: String; AType: Integer);
begin
  put(AType, AName);
  putValueString(AValue);
end;

procedure TDefaultMongoEncoder.putValueString(AValue: String);
var
  lenPos, strLen: Int64;
begin
  lenPos := FBuffer.Position;
  FBuffer.WriteInt(0); // making space for length
  strLen := put(AValue);
  FBuffer.writeInt(lenPos, strLen);
end;

procedure TDefaultMongoEncoder.PutInterfaceField(name: String; const val: IInterface);
var
  vBSONObject: IBSONObject;
  vBSONArray: IBSONArray;
  vBSONObjectId: IBSONObjectId;
  vBSONBinary: IBSONBinary;
  vBSONRegEx: IBSONRegEx;
  vBSONSymbol: IBSONSymbol;
  vBSONCode: IBSONCode;
  vBSONCode_W_Scope: IBSONCode_W_Scope;
  vBSONTimeStamp: IBSONTimeStamp;
  vBSONDBRef: IBSONDBRef;
begin
  if Supports(val, IBSONArray, vBSONArray) then
  begin
    put(BSON_ARRAY, name);
    Encode(vBSONArray);
  end
  else if Supports(val, IBSONBinary, vBSONBinary) then
  begin
    putBinary(name, vBSONBinary);
  end
  else if Supports(val, IBSONRegEx, vBSONRegEx) then
  begin
    putRegEx(name, vBSONRegEx);
  end
  else if Supports(val, IBSONDBRef, vBSONDBRef) then
  begin
    putDBRef(name, vBSONDBRef);
  end
  else if Supports(val, IBSONObject, vBSONObject) then
  begin
    putObject(name, vBSONObject);
  end
  else if Supports(val, IBSONSymbol, vBSONSymbol) then
  begin
    putString(name, vBSONSymbol.Symbol, BSON_SYMBOL);
  end
  else if Supports(val, IBSONCode, vBSONCode) then
  begin
    putString(name, vBSONCode.Code, BSON_CODE);
  end
  else if Supports(val, IBSONCode_W_Scope, vBSONCode_W_Scope) then
  begin
    putCodeWScope(name, vBSONCode_W_Scope);
  end
  else if Supports(val, IBSONTimeStamp, vBSONTimeStamp) then
  begin
    putTimeStamp(name, vBSONTimeStamp);
  end
  else if Supports(val, IBSONObjectId, vBSONObjectId) then
  begin
    putObjectId(name, vBSONObjectId);
  end;
end;

procedure TDefaultMongoEncoder.putObjectId(AName: String; const AValue: IBSONObjectId);
var
  OID: TBSONObjectIdByteArray;
begin
  put(BSON_OBJECTID, AName);

  OID := AValue.AsByteArray;

  FBuffer.Write(OID[0], 12);
end;

procedure TDefaultMongoEncoder.Encode(const ABSONObject: IBSONBasicObject);
var
  i: Integer;
  vStart: Integer;
  vItem: TBSONItem;
  vWroteId: Boolean;
begin
  if (FBuffer = nil) then
    raise EMongoBufferIsNotConfigured.CreateResFmt(@sMongoBufferIsNotConfigured, [ClassName]);

  vWroteId := False;
  vStart := FBuffer.Position;
  FBuffer.WriteInt(0); // making space for length

  if ABSONObject.HasOid then
  begin
    putObjectId(KEY_ID, ABSONObject.GetOid);
    vWroteId := True;
  end;

  for i := 0 to ABSONObject.Count-1 do
  begin
    vItem := ABSONObject.Item[i];

    if vWroteId and vItem.IsObjectId then
      Continue;

    PutObjectField(vItem);
  end;
  FBuffer.WriteByte(BSON_EOF);
  FBuffer.WriteInt(vStart, FBuffer.Position - vStart);
end;


procedure TDefaultMongoEncoder.putUUID(AName: String; AValue: TGUID);
begin
  put(BSON_BINARY, AName);
  FBuffer.WriteInt(SizeOf(TGUID));
  FBuffer.WriteByte(BSON_SUBTYPE_UUID);
  FBuffer.Write(AValue, SizeOf(TGUID));
end;

procedure TDefaultMongoEncoder.SetBuffer(ABuffer: TBSONStream);
begin
  FBuffer := ABuffer;
end;

procedure TDefaultMongoEncoder.putBinary(name: String;const val: IBSONBinary);
var
  vSize: Integer;
begin
  put(BSON_BINARY, name);

  vSize := val.Size;

  if (val.SubType = BSON_SUBTYPE_OLD_BINARY) then
    vSize := vSize + 4;

  FBuffer.WriteInt(vSize);
  FBuffer.WriteByte(val.SubType);
  if (val.SubType = BSON_SUBTYPE_OLD_BINARY) then
    FBuffer.WriteInt(vSize-4);

  FBuffer.WriteStream(val.Stream);
end;

procedure TDefaultMongoEncoder.putRegEx(name: String;const val: IBSONRegEx);
begin
  put(BSON_REGEX, name);
  put(val.Pattern);
  put(val.GetOptions);
end;

procedure TDefaultMongoEncoder.putCodeWScope(name: String;const val: IBSONCode_W_Scope);
var
  vPos: Integer;
begin
  put(BSON_CODE_W_SCOPE, name );
  vPos := FBuffer.Position;

  FBuffer.WriteInt(0); //reserved size
  putValueString(val.Code);

  Encode(val.Scope);

  FBuffer.WriteInt(vPos, FBuffer.Position - vPos);
end;

procedure TDefaultMongoEncoder.putTimeStamp(name: String; const val: IBSONTimeStamp);
begin
  put(BSON_TIMESTAMP, name);
  FBuffer.WriteInt(val.Inc);
  FBuffer.WriteInt(val.Time);
end;

procedure TDefaultMongoEncoder.putDBRef(name: String; const val: IBSONDBRef);
var
  vRef: IBSONObject;
begin
  vRef := TBSONObject.NewFrom('$ref', val.Collection)
                     .Put('$id', val.ObjectId.OID);

  putObject(name, vRef);
end;

procedure TDefaultMongoEncoder.putObject(name: String; const val: IBSONObject);
begin
  put(BSON_DOC, name);

  Encode(val);
end;

{ TMongoEncoderFactory }

class function TMongoEncoderFactory.DefaultEncoder: IMongoEncoder;
begin
  Result := TDefaultMongoEncoder.Create;
end;

end.

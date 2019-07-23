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
unit MongoDecoder;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses BSONStream, BSONTypes;

type
  IMongoDecoder = interface
    ['{FE47DC70-7349-4818-998C-BB0B15D78683}']

    function Decode(ABuffer: TBSONStream): IBSONObject;
    function DecodeFromBeginning(ABuffer: TBSONStream): IBSONObject;
  end;

  TDefaultMongoDecoder = class(TInterfacedObject, IMongoDecoder)
  private
    function DecodeElement(ACurrent: IBSONObject; ABuffer: TBSONStream): Boolean;
    function DecodeObject(ABuffer: TBSONStream): IBSONObject;
    function DecodeArray(ABuffer: TBSONStream): IBSONArray;
    function DecodeBinary(ABuffer: TBSONStream): Variant;
    function DecodeRegEx(ABuffer: TBSONStream): IBSONRegEx;
    function DecodeCode_W_Scope(ABuffer: TBSONStream): IBSONCode_W_Scope;
    function DecodeTimeStamp(ABuffer: TBSONStream): IBSONTimeStamp;
  public
    function Decode(ABuffer: TBSONStream): IBSONObject;
    function DecodeFromBeginning(ABuffer: TBSONStream): IBSONObject;
  end;

  TMongoDecoderFactory = class
  public
    class function DefaultDecoder(): IMongoDecoder;
  end;

implementation

uses MongoException, Classes, BSON, Variants, SysUtils, BSONDBRef;

{ TMongoDecoderFactory }

class function TMongoDecoderFactory.DefaultDecoder: IMongoDecoder;
begin
  Result := TDefaultMongoDecoder.Create;
end;

{ TDefaultMongoDecoder }

function TDefaultMongoDecoder.DecodeFromBeginning(ABuffer: TBSONStream): IBSONObject;
begin
  ABuffer.ReadInt; //Length
  ABuffer.ReadInt; //RequestId
  ABuffer.ReadInt; //ResponseTo
  ABuffer.ReadInt; //OpCode
  ABuffer.ReadInt; //Flags
  ABuffer.ReadInt64; //CursorId
  ABuffer.ReadInt; //StartingFrom
  ABuffer.ReadInt; //NumberReturned

  Result := Decode(ABuffer);
end;

function TDefaultMongoDecoder.Decode(ABuffer: TBSONStream): IBSONObject;
begin
  Result := DecodeObject(ABuffer);
end;

function TDefaultMongoDecoder.DecodeArray(ABuffer: TBSONStream): IBSONArray;
var
  vTemp: IBSONObject;
begin
  vTemp := DecodeObject(ABuffer);

  Result := TBSONArray.NewFromObject(vTemp)
end;

function TDefaultMongoDecoder.DecodeElement(ACurrent: IBSONObject; ABuffer: TBSONStream): Boolean;
var
  vType: Byte;
  vName: String;
begin
  ABuffer.Read(vType, 1);

  if (vType = BSON_EOF) then
  begin
    Result := False;
    Exit;
  end;

  vName := ABuffer.ReadCString;

  case vType of
    BSON_NULL: ACurrent.Put(vName, Null);
    BSON_FLOAT: ACurrent.Put(vName, ABuffer.ReadDouble);
    BSON_STRING: ACurrent.Put(vName, ABuffer.ReadUTF8String);
    BSON_DOC: ACurrent.Put(vName, DecodeObject(ABuffer));
    BSON_ARRAY: ACurrent.Put(vName, DecodeArray(ABuffer));
    BSON_OBJECTID: ACurrent.Put(vName, TBSONObjectId.NewFromOID(ABuffer.ReadObjectId));
    BSON_BOOLEAN: ACurrent.Put(vName, (ABuffer.ReadByte = BSON_BOOL_TRUE));
    BSON_DATETIME: ACurrent.Put(vName, VarFromDateTime((ABuffer.ReadInt64/MSecsPerDay) + UnixDateDelta));
    BSON_INT32: ACurrent.Put(vName, ABuffer.ReadInt);
    BSON_INT64: ACurrent.Put(vName, ABuffer.ReadInt64);
    BSON_BINARY: ACurrent.Put(vName, DecodeBinary(ABuffer));
    BSON_REGEX: ACurrent.Put(vName, DecodeRegEx(ABuffer));
    BSON_SYMBOL: ACurrent.Put(vName, TBSONSymbol.NewFrom(ABuffer.ReadUTF8String));
    BSON_CODE: ACurrent.Put(vName, TBSONCode.NewFrom(ABuffer.ReadUTF8String));
    BSON_CODE_W_SCOPE: ACurrent.Put(vName, DecodeCode_W_Scope(ABuffer));
    BSON_TIMESTAMP: ACurrent.Put(vName, DecodeTimeStamp(ABuffer));
    BSON_MINKEY: ACurrent.Put(vName, MIN_KEY);
    BSON_MAXKEY: ACurrent.Put(vName, MAX_KEY);
  else
    raise EDecodeBSONTypeException.CreateResFmt(@sDecodeBSONTypeException, [vType]);
  end;
  Result := True;
end;

function TDefaultMongoDecoder.DecodeObject(ABuffer: TBSONStream): IBSONObject;
var
  vPosition,
  vLength,
  vNumRead: Integer;
begin
  vPosition := ABuffer.Position;
  vLength := ABuffer.ReadInt;

  Result := TBSONObject.Create;

  while DecodeElement(Result, ABuffer) do;

  if Result.Contain('$ref') and Result.Contain('$id') then
  begin
    Result := TBSONDBRef.Create('', Result.Items['$ref'].AsString, TBSONObjectId.NewFromOID(Result.Items['$id'].AsString));
  end;
    
  vNumRead := (ABuffer.Position - vPosition);
  if vNumRead <> vLength then
    raise EDecodeResponseSizeError.CreateResFmt(@sDecodeResponseSizeError, [vNumRead, vLength]);
end;

function TDefaultMongoDecoder.DecodeBinary(ABuffer: TBSONStream): Variant;
const
  UUID_SIZE = 16;
var
  vSize, vOldBinarySize: Integer;
  vSubType: Byte;
  vGUID: TGUID;
  vBinary: IBSONBinary;
begin
  vSize := ABuffer.ReadInt;

  ABuffer.Read(vSubType, 1);

  case vSubType of
    BSON_SUBTYPE_GENERIC,
    BSON_SUBTYPE_USER:
      begin
        vBinary := TBSONBinary.Create(vSubType);
        vBinary.CopyFrom(ABuffer, vSize);

        Result := vBinary;
      end;
    BSON_SUBTYPE_OLD_BINARY:
      begin
        vOldBinarySize := ABuffer.ReadInt;

        if (vOldBinarySize + 4 <> vSize) then
          raise EDecodeResponseSizeError.CreateResFmt(@sInvalidBSONBinarySubtypeSize, [vSubType, vOldBinarySize, vSize]);

        vBinary := TBSONBinary.Create(vSubType);
        vBinary.CopyFrom(ABuffer, vOldBinarySize);

        Result := vBinary;
      end;
    BSON_SUBTYPE_UUID:
      begin
        if (vSize <> UUID_SIZE) then
          raise EDecodeResponseSizeError.CreateResFmt(@sInvalidBSONBinarySubtypeSize, [vSubType, vSize, UUID_SIZE]);

        ABuffer.Read(vGUID, SizeOf(TGUID));

        Result := GUIDToString(vGUID);
      end;
  end;
end;

function TDefaultMongoDecoder.DecodeRegEx(ABuffer: TBSONStream): IBSONRegEx;
begin
  Result := TBSONRegEx.Create;
  Result.Pattern := ABuffer.ReadCString;
  Result.SetOptions(ABuffer.ReadCString);
end;

function TDefaultMongoDecoder.DecodeCode_W_Scope(ABuffer: TBSONStream): IBSONCode_W_Scope;
var
  vCode: String;
  vScope: IBSONObject;
begin
  ABuffer.ReadInt;

  vCode := ABuffer.ReadUTF8String;
  vScope := DecodeObject(ABuffer);

  Result := TBSONCode_W_Scope.NewFrom(vCode, vScope);
end;

function TDefaultMongoDecoder.DecodeTimeStamp(ABuffer: TBSONStream): IBSONTimeStamp;
var
  vInc, vTime: Integer;
begin
  vInc := ABuffer.ReadInt;
  vTime := ABuffer.ReadInt;

  Result := TBSONTimeStamp.NewFrom(vTime, vInc);
end;

end.

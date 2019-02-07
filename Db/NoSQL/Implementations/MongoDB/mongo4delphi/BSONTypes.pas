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
unit BSONTypes;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses Classes, BSON;

const
  MIN_KEY = 'MinKey';
  MAX_KEY = 'MaxKey';

type
  TBSONItem = class;
  IBSONObject = interface;

  TDuplicatesAction = (daUpdateValue, daError);

  TBsonValueType = (bvtNull,
                    bvtBoolean, bvtInteger, bvtInt64, bvtDouble,
                    bvtDateTime, bvtString, bvtInterface);

  TBSONObjectIdByteArray = array[0..11] of byte;

  IBSONObjectId = interface
    ['{B666B7F9-2E6A-45EA-A686-BCF212821AAA}']
    function AsByteArray: TBSONObjectIdByteArray;
    function ToStringMongo: String;

    function GetOID: String;
    function IsNew: Boolean;

    property OID: String read GetOID;
  end;

  IBSONBinary = interface
  ['{37130A33-E87F-491B-8061-84C7F4A8AC1A}']
    function GetStream: TMemoryStream;
    function GetSize: Integer;
    function GetSubType: Integer;

    property Stream: TMemoryStream read GetStream;
    property Size: Integer read GetSize;
    property SubType: Integer read GetSubType;

    function CopyFrom(Source: TStream; Count: Int64): Int64;

    function Write(const Buffer; Count: Longint): Longint;
  end;

  IBSONRegEx = interface
  ['{504A4D84-3C11-49CA-8F11-2FAE90A18A38}']
    procedure SetCaseInsensitive_I(const Value: Boolean);
    procedure SetDotAll_S(const Value: Boolean);
    procedure SetVerbose_X(const Value: Boolean);
    procedure SetMultiline_M(const Value: Boolean);
    procedure SetPattern(const Value: String);
    procedure SetLocaleDependent_L(const Value: Boolean);
    procedure SetUnicode_U(const Value: Boolean);
    function GetCaseInsensitive_I: Boolean;
    function GetDotAll_S: Boolean;
    function GetVerbose_X: Boolean;
    function GetMultiline_M: Boolean;
    function GetPattern: String;
    function GetLocaleDependent_L: Boolean;
    function GetUnicode_U: Boolean;

    property Pattern: String read GetPattern write SetPattern;
    property CaseInsensitive_I: Boolean read GetCaseInsensitive_I write SetCaseInsensitive_I;
    property Multiline_M: Boolean read GetMultiline_M write SetMultiline_M;
    property Verbose_X: Boolean read GetVerbose_X write SetVerbose_X;
    property DotAll_S: Boolean read GetDotAll_S write SetDotAll_S;
    property LocaleDependent_L: Boolean read GetLocaleDependent_L write SetLocaleDependent_L;
    property Unicode_U: Boolean read GetUnicode_U write SetUnicode_U;

    function GetOptions: String;
    procedure SetOptions(const AOptions: String);
  end;

  IBSONSymbol = interface
  ['{D1889152-5905-494F-9F20-5EB2DC74130F}']

    procedure SetSymbol(const Value: String);
    function GetSymbol: String;

    property Symbol: String read GetSymbol write SetSymbol;
  end;

  IBSONCode = interface
  ['{40331741-7564-4696-A687-2623CFFEF828}']

    procedure SetCode(const Value: String);
    function GetCode: String;
    property Code: String read GetCode write SetCode;
  end;

  IBSONCode_W_Scope = interface
  ['{C108B8AC-0520-40FB-992F-D160A0160F77}']

    procedure SetCode(const Value: String);
    procedure SetScope(const Value: IBSONObject);
    function GetCode: String;
    function GetScope: IBSONObject;

    property Code: String read GetCode write SetCode;
    property Scope: IBSONObject read GetScope write SetScope;
  end;

  IBSONTimeStamp = interface
  ['{F0DC0073-5623-4D08-9A9B-67E97646579C}']

    procedure SetInc(const Value: Integer);
    procedure SetTime(const Value: Integer);
    function GetInc: Integer;
    function GetTime: Integer;

    property Time: Integer read GetTime write SetTime;
    property Inc: Integer read GetInc write SetInc;
  end;

  IBSONBasicObject = interface
    ['{FF4178D1-D45B-480D-9704-85ACD5BA02E9}']
    function GetItem(AIndex: Integer): TBSONItem;
    function GetItems(AKey: String): TBSONItem;

    property Item[AIndex: Integer]: TBSONItem read GetItem;default;
    property Items[AKey: String]: TBSONItem read GetItems;

    function Count: Integer;
    function HasOid: Boolean;
    function GetOid: IBSONObjectId;

    function AsJson: String;
    function AsJsonReadable: String;
  end;

  IBSONObject = interface(IBSONBasicObject)
    ['{BC5F07D7-0A81-40AF-9F09-E8DA38BC446C}']

    function GetDuplicatesAction: TDuplicatesAction;

    procedure SetDuplicatesAction(const Value: TDuplicatesAction);

    property DuplicatesAction: TDuplicatesAction read GetDuplicatesAction write SetDuplicatesAction;

    function Put(const AKey: String; Value: Variant): IBSONObject;
    function Find(const AKey: String): TBSONItem;overload;
    function Find(const AKey: String;var AIndex: Integer): Boolean;overload;
    function PutAll(const ASource: IBSONObject): IBSONObject;
    function Remove(const AKey: String): IBSONObject;

    function Contain(const AKey: String): Boolean;
  end;

  IBSONArray = interface(IBSONBasicObject)
    ['{ADA231EC-9BD6-4FEB-BCB7-56D88580319E}']
    function Put(Value: Variant): IBSONArray;overload;
    function Put(const AIndex: Integer; Value: Variant): IBSONArray;overload;
    function Insert(const AIndex: Integer; Value: Variant): IBSONArray;
    function Contain(const AKey: Integer): Boolean;
    function Remove(const AKey: Integer): IBSONArray;
  end;

  IBSONDBRef = interface(IBSONObject)
  ['{7D37491B-E323-4984-AC90-1747D8725BAF}']
    function GetCollection: String;
    function GetDB: String;
    function GetObjectId: IBSONObjectId;

    property DB: String read GetDB;
    property Collection: String read GetCollection;
    property ObjectId: IBSONObjectId read GetObjectId;

    //For internal use only
    function GetInstance: TObject;
  end;

  TBSONObjectId = class(TInterfacedObject, IBSONObjectId)
  private
    FOID: String;
    FNew: Boolean;

    procedure GenId;
    function GetOID: String;
  public
    constructor Create;overload;
    constructor Create(const OID: String);overload;

    class function NewFrom(): IBSONObjectId;
    class function NewFromOID(const OID: String): IBSONObjectId;

    function AsByteArray: TBSONObjectIdByteArray;
    function ToStringMongo: String;
    function IsNew: Boolean;

    property OID: String read GetOID;
  end;

  TBSONBinary = class(TInterfacedObject, IBSONBinary)
  private
    FStream: TMemoryStream;
    FSubType: Integer;
    function GetStream: TMemoryStream;
    function GetSubType: Integer;
    function GetSize: Integer;
  public
    constructor Create(ASubType: Integer = BSON_SUBTYPE_GENERIC);

    class function NewFromFile(AFileName: String; ASubType: Integer = BSON_SUBTYPE_GENERIC): IBSONBinary;
    class function NewFromStream(AStream: TStream; ASubType: Integer = BSON_SUBTYPE_GENERIC): IBSONBinary;

    destructor Destroy; override;

    property Stream: TMemoryStream read GetStream;
    property SubType: Integer read GetSubType;
    property Size: Integer read GetSize;

    function CopyFrom(Source: TStream; Count: Int64): Int64;

    function Write(const Buffer; Count: Longint): Longint;
  end;

  //Do not match the pattern in client-side
  TBSONRegEx = class(TInterfacedObject, IBSONRegEx)
  private
    FDotAll_S: Boolean;
    FMultiline_M: Boolean;
    FVerbose_X: Boolean;
    FCaseInsensitive_I: Boolean;
    FPattern: String;
    FUnicode_U: Boolean;
    FLocaleDependent_L: Boolean;
    procedure SetCaseInsensitive_I(const Value: Boolean);
    procedure SetDotAll_S(const Value: Boolean);
    procedure SetVerbose_X(const Value: Boolean);
    procedure SetMultiline_M(const Value: Boolean);
    procedure SetPattern(const Value: String);
    procedure SetLocaleDependent_L(const Value: Boolean);
    procedure SetUnicode_U(const Value: Boolean);
    function GetCaseInsensitive_I: Boolean;
    function GetDotAll_S: Boolean;
    function GetVerbose_X: Boolean;
    function GetMultiline_M: Boolean;
    function GetPattern: String;
    function GetLocaleDependent_L: Boolean;
    function GetUnicode_U: Boolean;
  public
    property Pattern: String read GetPattern write SetPattern;
    property CaseInsensitive_I: Boolean read GetCaseInsensitive_I write SetCaseInsensitive_I;
    property Multiline_M: Boolean read GetMultiline_M write SetMultiline_M;
    property Verbose_X: Boolean read GetVerbose_X write SetVerbose_X;
    property DotAll_S: Boolean read GetDotAll_S write SetDotAll_S;
    property LocaleDependent_L: Boolean read GetLocaleDependent_L write SetLocaleDependent_L;
    property Unicode_U: Boolean read GetUnicode_U write SetUnicode_U;

    function GetOptions: String;
    procedure SetOptions(const AOptions: String);

    class function NewFrom(APattern: String; AOptions: String=''): IBSONRegEx;
  end;

  TBSONSymbol = class(TInterfacedObject, IBSONSymbol)
  private
    FSymbol: String;
    procedure SetSymbol(const Value: String);
    function GetSymbol: String;
  public
    property Symbol: String read GetSymbol write SetSymbol;

    class function NewFrom(const ASymbol: String): IBSONSymbol;
  end;

  TBSONCode = class(TInterfacedObject, IBSONCode)
  private
    FCode: String;
    procedure SetCode(const Value: String);
    function GetCode: String;
  public
    property Code: String read GetCode write SetCode;

    class function NewFrom(const ACode: String): IBSONCode;
  end;

  TBSONCode_W_Scope = class(TInterfacedObject, IBSONCode_W_Scope)
  private
    FCode: String;
    FScope: IBSONObject;
    procedure SetCode(const Value: String);
    procedure SetScope(const Value: IBSONObject);
    function GetCode: String;
    function GetScope: IBSONObject;
  public
    property Code: String read GetCode write SetCode;
    property Scope: IBSONObject read GetScope write SetScope;

    class function NewFrom(const ACode: String;const AScope: IBSONObject): IBSONCode_W_Scope;
  end;

  TBSONTimeStamp = class(TInterfacedObject, IBSONTimeStamp)
  private
    FTime: Integer;
    FInc: Integer;
    procedure SetInc(const Value: Integer);
    procedure SetTime(const Value: Integer);
    function GetInc: Integer;
    function GetTime: Integer;
  public
    property Time: Integer read GetTime write SetTime;
    property Inc: Integer read GetInc write SetInc;

    class function NewFrom(const ATime, AInc: Integer): IBSONTimeStamp;
  end;

  TBSONItem = class
  private
    FName: String;
    FValue: Variant;
    FValueType: TBsonValueType;

    procedure SetValue(const Value: Variant);

    //for internal use only, in BSONArray re-order
    procedure SetName(const Value: String);

    function GetAsObjectId: IBSONObjectId;
    function GetAsInteger: Integer;
    function GetAsInt64: Int64;
    function GetAsString: String;
    function GetAsDateTime: TDateTime;
    function GetAsFloat: Double;
    function GetAsBoolean: Boolean;
    function GetAsBSONObject: IBSONObject;
    function GetAsBSONArray: IBSONArray;
    function GetAsBSONBinary: IBSONBinary;
    function GetAsBSONRegEx: IBSONRegEx;
    function GetAsBSONSymbol: IBSONSymbol;
    function GetAsBSONCode: IBSONCode;
    function GetAsBSONCode_W_Scope: IBSONCode_W_Scope;
    function GetAsBSONTimeStamp: IBSONTimeStamp;
    function GetAsBSONDBRef: IBSONDBRef;
  public
    property Name: String read FName;
    property Value: Variant read FValue write SetValue;
    property ValueType: TBsonValueType read FValueType;
    property AsObjectId: IBSONObjectId read GetAsObjectId;
    property AsInteger: Integer read GetAsInteger;
    property AsInt64: Int64 read GetAsInt64;
    property AsString: String read GetAsString;
    property AsDateTime: TDateTime read GetAsDateTime;
    property AsFloat: Double read GetAsFloat;
    property AsBoolean: Boolean read GetAsBoolean;
    property AsBSONObject: IBSONObject read GetAsBSONObject;
    property AsBSONArray: IBSONArray read GetAsBSONArray;
    property AsBSONBinary: IBSONBinary read GetAsBSONBinary;
    property AsBSONRegEx: IBSONRegEx read GetAsBSONRegEx;
    property AsBSONSymbol: IBSONSymbol read GetAsBSONSymbol;
    property AsBSONCode: IBSONCode read GetAsBSONCode;
    property AsBSONCode_W_Scope: IBSONCode_W_Scope read GetAsBSONCode_W_Scope;
    property AsBSONTimeStamp: IBSONTimeStamp read GetAsBSONTimeStamp;
    property AsBSONDBRef: IBSONDBRef read GetAsBSONDBRef;

    function GetValueTypeDesc: String;

    function IsInteger: Boolean;
    function IsObjectId: Boolean;
    function IsMinKey: Boolean;
    function IsMaxKey: Boolean;

    class function NewFrom(AName: String;const AValue: Variant): TBSONItem;
  end;

  TBSONObject = class(TInterfacedObject, IBSONObject)
  private
    FMap: TStringList;
    FDuplicatesAction: TDuplicatesAction;
  protected
    procedure PushItem(AIndex: Integer; AItem: TBSONItem);virtual;
    function GetItems(AKey: String): TBSONItem;
    function GetItem(AIndex: Integer): TBSONItem;
    procedure SetDuplicatesAction(const Value: TDuplicatesAction);
    function GetDuplicatesAction: TDuplicatesAction;
    function InternalPut(AIndex: Integer; const AKey: String; Value: Variant): IBSONObject;
  public
    constructor Create;
    destructor Destroy; override;

    class function NewFrom(const AKey: String; Value: Variant): IBSONObject;
    class function EMPTY: IBSONObject;

    property DuplicatesAction: TDuplicatesAction read GetDuplicatesAction write SetDuplicatesAction default daUpdateValue;

    property Items[AKey: String]: TBSONItem read GetItems;
    property Item[AIndex: Integer]: TBSONItem read GetItem;default;

    function Put(const AKey: String; Value: Variant): IBSONObject;
    function Find(const AKey: String): TBSONItem;overload;
    function Find(const AKey: String;var AIndex: Integer): Boolean;overload;
    function Count: Integer;

    function PutAll(const ASource: IBSONObject): IBSONObject;

    function HasOid: Boolean;
    function GetOid: IBSONObjectId;

    function Contain(const AKey: String): Boolean;

    function Remove(const AKey: String): IBSONObject;

    function AsJson: String;
    function AsJsonReadable: String;
  end;

  TBSONArray = class(TBSONObject, IBSONArray)
  private
    procedure RenameItemFromIndex(AIndex: Integer);
  public
    function Put(Value: Variant): IBSONArray;overload;
    function Put(const AIndex: Integer; Value: Variant): IBSONArray;overload;
    function Insert(const AIndex: Integer; Value: Variant): IBSONArray;

    function Contain(const AKey: Integer): Boolean;
    function Remove(const AKey: Integer): IBSONArray;

    class function NewFrom(Value: Variant): IBSONArray;
    class function NewFromValues(Values:Array of Variant): IBSONArray;
    class function NewFromObject(Value: IBSONObject): IBSONArray;
    class function NewFromTStrings(Value: TStrings): IBSONArray;
  end;

  TBSONObjectQueryHelper = class
  private
  public
    //All items must contain a _id field

    class function NewFilterOid(AObjects: IBSONObject): IBSONObject;
    class function NewFilterBatchOID(AObjects: Array of IBSONObject): IBSONObject;
  end;

implementation

uses SysUtils, Variants, MongoUtils,
  MongoException, TypInfo, StrUtils, DateUtils, JsonWriter,
  BSONObjectIdGenerator;

{ TBSONObjectId }

function TBSONObjectId.AsByteArray: TBSONObjectIdByteArray;
var
  vStringOID: String;
  i, j: Integer;
  vByte: Byte;
begin
  vStringOID := ToStringMongo;
  j := length(BSON_OBJECTID_PREFIX)+1;
  for i:=0 to 11 do
  begin
    vByte := byte(AnsiChar(vStringOID[j+i*2]));

    if (vByte and $F0) = $30 then
      Result[i] := vByte shl 4
    else
      Result[i] := (9+vByte) shl 4;

    vByte := byte(AnsiChar(vStringOID[j+i*2+1]));
    
    if (vByte and $F0)=$30 then
      inc(Result[i], vByte and $F)
    else
      inc(Result[i],(9+ vByte) and $F);
  end;
end;

constructor TBSONObjectId.Create;
begin
  inherited;

  GenId;

  FNew := True;
end;

constructor TBSONObjectId.Create(const OID: String);
begin
  inherited Create;

  FOID := OID;

  FNew := False;
end;

procedure TBSONObjectId.GenId;
begin
  FOID := TBSONObjectIdGenerator.GenId;
end;

function TBSONObjectId.GetOID: String;
begin
  Result := FOID;
end;

function TBSONObjectId.IsNew: Boolean;
begin
  Result := FNew;
end;

class function TBSONObjectId.NewFrom: IBSONObjectId;
begin
  Result := TBSONObjectId.Create;
end;

class function TBSONObjectId.NewFromOID(const OID: String): IBSONObjectId;
begin
  Result := TBSONObjectId.Create(OID);
end;

function TBSONObjectId.ToStringMongo: String;
begin
  Result := Format('%s%s%s', [BSON_OBJECTID_PREFIX, FOID, BSON_OBJECTID_SUFIX]);
end;

{ TBSONObject }

function TBSONObject.Count: Integer;
begin
  Result := FMap.Count;
end;

constructor TBSONObject.Create;
begin
  FMap := TStringList.Create;
  FDuplicatesAction := daUpdateValue;
end;

destructor TBSONObject.Destroy;
begin
  TListUtils.FreeObjects(FMap);
  FMap.Free;
  inherited;
end;

function TBSONObject.Find(const AKey: String): TBSONItem;
var
  vIndex: Integer;
begin
  Result := nil;

  if Find(AKey, vIndex) then
  begin
    Result := Item[vIndex];
  end;
end;

class function TBSONObject.EMPTY: IBSONObject;
begin
  Result := TBSONObject.Create;
end;

function TBSONObject.Find(const AKey: String;var AIndex: Integer): Boolean;
begin
  AIndex := FMap.IndexOf(AKey);

  Result := (AIndex >= 0);
end;

function TBSONObject.GetDuplicatesAction: TDuplicatesAction;
begin
  Result := FDuplicatesAction;
end;

function TBSONObject.GetItem(AIndex: Integer): TBSONItem;
begin
  Result := TBSONItem(FMap.Objects[AIndex]);
end;

function TBSONObject.GetItems(AKey: String): TBSONItem;
begin
  Result := Find(AKey);

  if (Result = nil) then
  begin
    Result := TBSONItem.NewFrom(AKey, Null);

    PushItem(Count, Result);
  end;
end;

class function TBSONObject.NewFrom(const AKey: String;Value: Variant): IBSONObject;
begin
  Result := TBSONObject.Create;
  Result.Put(AKey, Value);
end;

procedure TBSONObject.PushItem(AIndex: Integer; AItem: TBSONItem);
begin
  while (AIndex > Count) do
  begin
    PushItem(Count, TBSONItem.NewFrom(IntToStr(Count), Null));
  end;

  FMap.InsertObject(AIndex, AItem.Name, AItem);
end;

function TBSONObject.Put(const AKey: String; Value: Variant): IBSONObject;
begin
  Result := InternalPut(Count, AKey, Value);
end;

function TBSONObject.PutAll(const ASource: IBSONObject): IBSONObject;
var
  i: Integer;
begin
  for i := 0 to ASource.Count-1 do
  begin
    Put(ASource[i].Name, ASource[i].Value);
  end;
  Result := Self;
end;

procedure TBSONObject.SetDuplicatesAction(const Value: TDuplicatesAction);
begin
  if (FDuplicatesAction <> Value) then
  begin
    if (Count > 0) then
      raise EBSONCannotChangeDuplicateAction.CreateRes(@sBSONCannotChangeDuplicateAction);

    FDuplicatesAction := Value;
  end;
end;

function TBSONObject.HasOid: Boolean;
var
  vItem: TBSONItem;
begin
  vItem := Find(KEY_ID);

  Result := Assigned(vItem) and Assigned(vItem.AsObjectId);
end;

function TBSONObject.GetOid: IBSONObjectId;
var
  vIndex: Integer;
  vItem: TBSONItem;
begin
  Result := nil;

  if Find(KEY_ID, vIndex) then
  begin
    vItem := Item[vIndex];

    Result := vItem.AsObjectId;
  end;

  if (Result = nil) then
  begin
    raise EBSONObjectHasNoObjectId.CreateRes(@sBSONObjectHasNoObjectId);
  end;
end;

function TBSONObject.Contain(const AKey: String): Boolean;
var
  vIndex: Integer;
begin
  Result := Find(AKey, vIndex);
end;

function TBSONObject.AsJson: String;
var
  vWriter: TJsonWriter;
begin
  vWriter := TJsonWriter.Create;
  try
    Result := vWriter.ToJson(Self);
  finally
    vWriter.Free;
  end;
end;

function TBSONObject.AsJsonReadable: String;
var
  vWriter: TJsonWriter;
begin
  vWriter := TJsonWriter.Create;
  try
    Result := vWriter.ToJsonReadable(Self);
  finally
    vWriter.Free;
  end;
end;

function TBSONObject.Remove(const AKey: String): IBSONObject;
var
  vIndex: Integer;
begin
  if Find(AKey, vIndex) then
  begin
    Item[vIndex].Free;
    FMap.Delete(vIndex);
  end;

  Result := Self;
end;

function TBSONObject.InternalPut(AIndex: Integer; const AKey: String;Value: Variant): IBSONObject;
var
  vItem: TBSONItem;
begin
  vItem := Find(AKey);

  if Assigned(vItem) then
  begin
    if (FDuplicatesAction = daError) then
      raise EBSONDuplicateKeyInList.CreateResFmt(@sBSONDuplicateKeyInList, [AKey]);

    vItem.Value := Value;
  end
  else
  begin
    PushItem(AIndex, TBSONItem.NewFrom(AKey, Value));
  end;

  Result := Self;
end;

{ TBSONItem }

function TBSONItem.GetAsBSONBinary: IBSONBinary;
begin
  Result := nil;
  if (FValueType = bvtInterface) then
  begin
    Supports(IUnknown(FValue), IBSONBinary, Result);
  end;
end;

function TBSONItem.GetAsBoolean: Boolean;
begin
  if (FValueType = bvtBoolean) then
    Result := FValue
  else
    raise EBSONValueConvertError.CreateResFmt(@sBSONValueConvertError, ['Boolean']);
end;

function TBSONItem.GetAsBSONArray: IBSONArray;
begin
  Result := nil;
  if (FValueType = bvtInterface) then
  begin
    Supports(IUnknown(FValue), IBSONArray, Result);
  end;
end;

function TBSONItem.GetAsBSONObject: IBSONObject;
begin
  Result := nil;
  if (FValueType = bvtInterface) then
  begin
    Supports(IUnknown(FValue), IBSONObject, Result);
  end;
end;

function TBSONItem.GetAsDateTime: TDateTime;
begin
  if (FValueType = bvtDateTime) then
    Result := VarToDateTime(FValue)
  else
    raise EBSONValueConvertError.CreateResFmt(@sBSONValueConvertError, ['TDateTime']);
end;

function TBSONItem.GetAsFloat: Double;
begin
  if (FValueType = bvtDouble) or IsInteger then
    Result := FValue
  else
    raise EBSONValueConvertError.CreateResFmt(@sBSONValueConvertError, ['Double']);
end;

function TBSONItem.GetAsInt64: Int64;
begin
  if IsInteger then
    Result := FValue
  else
    raise EBSONValueConvertError.CreateResFmt(@sBSONValueConvertError, ['Int64']);
end;

function TBSONItem.GetAsInteger: Integer;
begin
  Result := AsInt64;
end;

function TBSONItem.GetAsObjectId: IBSONObjectId;
begin
  Result := nil;
  if (FValueType = bvtInterface) then
  begin
    Supports(IUnknown(FValue), IBSONObjectId, Result);
  end;
end;

function TBSONItem.GetAsString: String;
begin
  Result := VarToStr(FValue);
end;

function TBSONItem.GetValueTypeDesc: String;
begin
  Result := GetEnumName(TypeInfo(TBsonValueType), Ord(FValueType));
end;

function TBSONItem.IsInteger: Boolean;
begin
  Result := FValueType in [bvtInteger, bvtInt64];
end;

function TBSONItem.IsObjectId: Boolean;
begin
  Result := (FValueType = bvtInterface) and
              Supports(IUnknown(FValue), IBSONObjectId);
end;

class function TBSONItem.NewFrom(AName: String;const AValue: Variant): TBSONItem;
begin
  Result := TBSONItem.Create;
  Result.FName := AName;
  Result.SetValue(AValue);
end;

procedure TBSONItem.SetValue(const Value: Variant);
var
  vTempValue: Extended;
begin
  FValue := Value;

  FValueType := bvtNull;
  case VarType(FValue) and varTypeMask of
    varEmpty, varNull: ;
    varDate: FValueType := bvtDateTime;
    varByte, varSmallint,varInteger,varShortInt,varWord,varLongWord: FValueType := bvtInteger;
    varInt64: FValueType := bvtInt64;
    varSingle,varDouble,varCurrency: begin
                                       vTempValue := FValue;
                                       if Frac(vTempValue) <= 0.00001 then
                                         FValueType := bvtInteger
                                       else
                                         FValueType := bvtDouble;
                                     end;  
    varOleStr, varString{$IFDEF UNICODE}, varUString{$ENDIF}: FValueType := bvtString;
    varBoolean: FValueType := bvtBoolean;
    varDispatch, varUnknown: FValueType := bvtInterface;
  else
    raise EBSONValueTypeUnknown.CreateResFmt(@sBSONValueTypeUnknown, [IntToHex(VarType(FValue), 4)]);
  end;
end;

function TBSONItem.GetAsBSONRegEx: IBSONRegEx;
begin
  Result := nil;
  if (FValueType = bvtInterface) then
  begin
    Supports(IUnknown(FValue), IBSONRegEx, Result);
  end;
end;

function TBSONItem.GetAsBSONSymbol: IBSONSymbol;
begin
  Result := nil;
  if (FValueType = bvtInterface) then
  begin
    Supports(IUnknown(FValue), IBSONSymbol, Result);
  end;
end;

function TBSONItem.GetAsBSONCode: IBSONCode;
begin
  Result := nil;
  if (FValueType = bvtInterface) then
  begin
    Supports(IUnknown(FValue), IBSONCode, Result);
  end;
end;

function TBSONItem.GetAsBSONCode_W_Scope: IBSONCode_W_Scope;
begin
  Result := nil;
  if (FValueType = bvtInterface) then
  begin
    Supports(IUnknown(FValue), IBSONCode_W_Scope, Result);
  end;
end;

function TBSONItem.GetAsBSONTimeStamp: IBSONTimeStamp;
begin
  Result := nil;
  if (FValueType = bvtInterface) then
  begin
    Supports(IUnknown(FValue), IBSONTimeStamp, Result);
  end;
end;

function TBSONItem.IsMinKey: Boolean;
begin
  Result := (FValue = MIN_KEY);
end;

function TBSONItem.IsMaxKey: Boolean;
begin
  Result := (FValue = MAX_KEY);
end;

function TBSONItem.GetAsBSONDBRef: IBSONDBRef;
begin
  Result := nil;
  if (FValueType = bvtInterface) then
  begin
    Supports(IUnknown(FValue), IBSONDBRef, Result);
  end;
end;

procedure TBSONItem.SetName(const Value: String);
begin
  FName := Value;
end;

{ TBSONArray }

function TBSONArray.Contain(const AKey: Integer): Boolean;
begin
  Result := (AKey >= 0) and (AKey < Count);
end;

function TBSONArray.Insert(const AIndex: Integer;Value: Variant): IBSONArray;
begin
  inherited PushItem(AIndex, TBSONItem.NewFrom(IntToStr(AIndex), Value));

  RenameItemFromIndex(AIndex);

  Result := Self;
end;

class function TBSONArray.NewFrom(Value: Variant): IBSONArray;
begin
  Result := TBSONArray.Create;
  Result.Put(Value);
end;

class function TBSONArray.NewFromObject(Value: IBSONObject): IBSONArray;
var
  i: Integer;
begin
  Result := TBSONArray.Create;

  for i := 0 to Value.Count-1 do
  begin
    Result.Put(Value[i].Value);
  end;
end;

class function TBSONArray.NewFromTStrings(Value: TStrings): IBSONArray;
var
  i: Integer;
begin
  Result := TBSONArray.Create;

  for i := 0 to Value.Count-1 do
  begin
    Result.Put(Value[i]);
  end;
end;

class function TBSONArray.NewFromValues(Values: array of Variant): IBSONArray;
var
  i: Integer;
begin
  Result := TBSONArray.Create;

  for i := Low(Values) to High(Values) do
  begin
    Result.Put(Values[i]);
  end;
end;

function TBSONArray.Put(Value: Variant): IBSONArray;
begin
  Result := Insert(Count, Value);
end;

function TBSONArray.Put(const AIndex: Integer; Value: Variant): IBSONArray;
begin
  if Contain(AIndex) then
  begin
    Item[AIndex].Value := Value;
  end
  else
  begin
    Insert(AIndex, Value);
  end;

  Result := Self;
end;

function TBSONArray.Remove(const AKey: Integer): IBSONArray;
begin
  inherited Remove(IntToStr(AKey));

  RenameItemFromIndex(AKey-1);

  Result := Self;
end;

procedure TBSONArray.RenameItemFromIndex(AIndex: Integer);
var
  i: Integer;
begin
  if (AIndex < Count-1) then
  begin
    for i := AIndex to Count-1 do
    begin
      Item[i].SetName(IntToStr(i));
    end;
  end;
end;

{ TBSONObjectQueryHelper }

class function TBSONObjectQueryHelper.NewFilterBatchOID(AObjects: array of IBSONObject): IBSONObject;
var
  i: Integer;
  vOidArray: IBSONArray;
begin
  Result := TBSONObject.Create;

  vOidArray := TBSONArray.Create;
  
  for i := Low(AObjects) to High(AObjects) do
  begin
    vOidArray.Put(AObjects[i].GetOid);
  end;

  Result  := TBSONObject.NewFrom(KEY_ID, TBSONObject.NewFrom('$in', vOidArray));
end;

class function TBSONObjectQueryHelper.NewFilterOid(AObjects: IBSONObject): IBSONObject;
begin
  Result  := TBSONObject.NewFrom(KEY_ID, AObjects.GetOid);
end;

{ TBSONBinary }

function TBSONBinary.CopyFrom(Source: TStream; Count: Int64): Int64;
begin
  Result := Count;
  if (Count > 0) then
  begin
    FStream.CopyFrom(Source, Count);
  end;
end;

constructor TBSONBinary.Create(ASubType: Integer);
begin
  inherited Create;

  if not(ASubType in [BSON_SUBTYPE_GENERIC, BSON_SUBTYPE_OLD_BINARY, BSON_SUBTYPE_USER]) then
  begin
    raise EIllegalArgumentException.CreateResFmt(@sInvalidBSONBinarySubtype, [ASubType]);
  end;

  FStream := TMemoryStream.Create;
  FSubType := ASubType;
end;

destructor TBSONBinary.Destroy;
begin
  FStream.Free;
  inherited;
end;

function TBSONBinary.GetSize: Integer;
begin
  Result := FStream.Size;
end;

function TBSONBinary.GetStream: TMemoryStream;
begin
  Result := FStream;
end;

function TBSONBinary.GetSubType: Integer;
begin
  Result := FSubType;
end;

class function TBSONBinary.NewFromFile(AFileName: String; ASubType: Integer): IBSONBinary;
begin
  Result := TBSONBinary.Create(ASubType);
  Result.Stream.LoadFromFile(AFileName);
end;

class function TBSONBinary.NewFromStream(AStream: TStream;ASubType: Integer): IBSONBinary;
begin
  Result := TBSONBinary.Create(ASubType);
  Result.CopyFrom(AStream, AStream.Size);
end;

function TBSONBinary.Write(const Buffer; Count: Integer): Longint;
begin
  Result := FStream.Write(Buffer, Count);
end;

{ TBSONRegEx }

function TBSONRegEx.GetCaseInsensitive_I: Boolean;
begin
  Result := FCaseInsensitive_I;
end;

function TBSONRegEx.GetDotAll_S: Boolean;
begin
  Result := FDotAll_S;
end;

function TBSONRegEx.GetVerbose_X: Boolean;
begin
  Result := FVerbose_X;
end;

function TBSONRegEx.GetMultiline_M: Boolean;
begin
  Result := FMultiline_M;
end;

function TBSONRegEx.GetOptions: String;
begin
  Result := IfThen(FCaseInsensitive_I, 'i');
  Result := Result + IfThen(FLocaleDependent_L, 'l');
  Result := Result + IfThen(FMultiline_M, 'm');
  Result := Result + IfThen(FDotAll_S, 's');
  Result := Result + IfThen(FUnicode_U, 'u');
  Result := Result + IfThen(FVerbose_X, 'x');
end;

function TBSONRegEx.GetPattern: String;
begin
  Result := FPattern;
end;

procedure TBSONRegEx.SetCaseInsensitive_I(const Value: Boolean);
begin
  FCaseInsensitive_I := Value;
end;

procedure TBSONRegEx.SetDotAll_S(const Value: Boolean);
begin
  FDotAll_S := Value;
end;

procedure TBSONRegEx.SetVerbose_X(const Value: Boolean);
begin
  FVerbose_X := Value;
end;

procedure TBSONRegEx.SetMultiline_M(const Value: Boolean);
begin
  FMultiline_M := Value;
end;

procedure TBSONRegEx.SetOptions(const AOptions: String);
var
  i: Integer;
begin
  for i := 1 to Length(AOptions) do
  begin
    case AOptions[i] of
      'i', 'I': FCaseInsensitive_I := True;
      'l', 'L': FLocaleDependent_L := True;
      'm', 'M': FMultiline_M := True;
      's', 'S': FDotAll_S := True;
      'u', 'U': FUnicode_U := True;
      'x', 'X': FVerbose_X := True;  
    else
      raise EBSONUnrecognizedRegExOption.CreateResFmt(@sBSONUnrecognizedRegExOption, [AOptions[i]]); 
    end;
  end;
end;

procedure TBSONRegEx.SetPattern(const Value: String);
begin
  FPattern := Value;
end;

procedure TBSONRegEx.SetLocaleDependent_L(const Value: Boolean);
begin
  FLocaleDependent_L := Value;
end;

procedure TBSONRegEx.SetUnicode_U(const Value: Boolean);
begin
  FUnicode_U := Value;
end;

function TBSONRegEx.GetLocaleDependent_L: Boolean;
begin
  Result := FLocaleDependent_L;
end;

function TBSONRegEx.GetUnicode_U: Boolean;
begin
  Result := FUnicode_U;
end;

class function TBSONRegEx.NewFrom(APattern, AOptions: String): IBSONRegEx;
begin
  Result := TBSONRegEx.Create;
  Result.Pattern := APattern;
  Result.SetOptions(AOptions);
end;

{ TBSONSymbol }

function TBSONSymbol.GetSymbol: String;
begin
  Result := FSymbol;
end;

class function TBSONSymbol.NewFrom(const ASymbol: String): IBSONSymbol;
begin
  Result := TBSONSymbol.Create;
  Result.Symbol := ASymbol;
end;

procedure TBSONSymbol.SetSymbol(const Value: String);
begin
  FSymbol := Value;
end;

{ TBSONCode }

function TBSONCode.GetCode: String;
begin
  Result := FCode;
end;

class function TBSONCode.NewFrom(const ACode: String): IBSONCode;
begin
  Result := TBSONCode.Create;
  Result.Code := ACode;
end;

procedure TBSONCode.SetCode(const Value: String);
begin
  FCode := Value;
end;

{ TBSONCode_W_Scope }

function TBSONCode_W_Scope.GetCode: String;
begin
  Result := FCode;
end;

function TBSONCode_W_Scope.GetScope: IBSONObject;
begin
  Result := FScope;
end;

class function TBSONCode_W_Scope.NewFrom(const ACode: String; const AScope: IBSONObject): IBSONCode_W_Scope;
begin
  Result := TBSONCode_W_Scope.Create;
  Result.Code := ACode;
  Result.Scope := AScope;
end;

procedure TBSONCode_W_Scope.SetCode(const Value: String);
begin
  FCode := Value;
end;

procedure TBSONCode_W_Scope.SetScope(const Value: IBSONObject);
begin
  FScope := Value;
end;

{ TBSONTimeStamp }

function TBSONTimeStamp.GetInc: Integer;
begin
  Result := FInc;
end;

function TBSONTimeStamp.GetTime: Integer;
begin
  Result := FTime;
end;

class function TBSONTimeStamp.NewFrom(const ATime,AInc: Integer): IBSONTimeStamp;
begin
  Result := TBSONTimeStamp.Create;
  Result.Time := ATime;
  Result.Inc := AInc;
end;

procedure TBSONTimeStamp.SetInc(const Value: Integer);
begin
  FInc := Value;
end;

procedure TBSONTimeStamp.SetTime(const Value: Integer);
begin
  FTime := Value;
end;

end.

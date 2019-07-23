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
unit MongoException;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses SysUtils;

type
  EMongoException = class(Exception)
  private
    FCode: Integer;
  public
    property Code: Integer read FCode;

    constructor Create(ACode: Integer; const Msg: string);overload;
    constructor Create(const Msg: string);overload;
  end;

  EMongoAuthenticationFailed = class(EMongoException)
  public
    constructor Create(ACode: Integer; const Msg: string);reintroduce;
  end;

  EIllegalArgumentException = class(EMongoException);
  EMongoConnectionFailureException = class(EMongoException);
  EMongoBufferIsNotConfigured = class(EMongoException);

  EMongoDBCursorException = class(EMongoException);
  EMongoDBCursorStateException = class(EMongoDBCursorException);

  ECommandFailure = class(EMongoException);

  EMongoDuplicateKey = class(EMongoException);

  EMongoProviderException = class(EMongoException);
  EMongoInvalidResponse = class(EMongoProviderException);
  EMongoReponseAborted = class(EMongoProviderException);

  EMongoDBNotEquals = class(EMongoException);

  EBSONTypesException = class(EMongoException);
  EBSONDuplicateKeyInList = class(EBSONTypesException);
  EBSONCannotChangeDuplicateAction = class(EBSONTypesException);
  EBSONObjectHasNoObjectId = class(EBSONTypesException);
  EBSONValueConvertError = class(EBSONTypesException);
  EBSONValueTypeUnknown = class(EBSONTypesException);
  EBSONUnrecognizedRegExOption = class(EBSONTypesException);

  EMongoDecoderException = class(EMongoException);
  EDecodeBSONTypeException = class(EMongoDecoderException);
  EDecodeResponseSizeError = class(EMongoDecoderException);

resourcestring
  sInvalidVariantValueType = 'Can''t serialize type "%s".';
  sMongoConnectionFailureException = 'failed to connect to "%s:%d"';
  sMongoBufferIsNotConfigured = 'Buffer is not configured for "%s".';
  sBSONDuplicateKeyInList = 'Key "%s" already exist.';
  sBSONCannotChangeDuplicateAction = 'Cannot change duplicate action after items added ';
  sMongoDBCursorStateException = 'Cannot change state after open query.';
  sMongoInvalidResponse = 'Invalid response for requestId "%d".';
  sMongoReponseAborted = 'Response aborted for requestId "%d".';
  sBSONObjectHasNoObjectId = 'Object has no "_id" field.';
  sBSONValueConvertError = 'Cannot convert the value to %s.';
  sBSONValueTypeUnknown = 'Type "%s" not implemented.';
  sDecodeBSONTypeException = 'Decoder not implements the type "%d".';
  sDecodeResponseSizeError = 'Bad data. Lengths don''t match read:"%d" != len:"%d"';
  sInvalidBSONBinarySubtype = 'Invalid subtype "%d", only are accepted values "BSON_SUBTYPE_GENERIC" and "BSON_SUBTYPE_OLD_BINARY(deprecated)".';
  sInvalidBSONBinarySubtypeSize = 'bad data size subtype "%d" len: %d totalLen: %d';
  sBSONUnrecognizedRegExOption = 'Unrecognized regex flag "%s".';
  sNotAGridFSObject = 'Not a GridFS object.';

implementation

{ EMongoException }

constructor EMongoException.Create(ACode: Integer; const Msg: string);
begin
  inherited Create(Msg);
  FCode := ACode;
end;

constructor EMongoException.Create(const Msg: string);
begin
  inherited Create(Msg);
end;

{ EMongoAuthenticationFailed }

constructor EMongoAuthenticationFailed.Create(ACode: Integer; const Msg: string);
begin
  inherited Create(Format('%s [code:%d]', [Msg, ACode]));
end;

end.

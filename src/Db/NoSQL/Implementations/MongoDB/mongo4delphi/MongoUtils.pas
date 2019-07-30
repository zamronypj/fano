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
unit MongoUtils;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses Classes;

const
  DEFAULT_HOST = 'localhost';
  DEFAULT_PORT = 27017;

  (* Mongo Collections *)
  COMMAND_COLLECTION = '$cmd';
  SYSTEM_INDEXES_COLLECTION = 'system.indexes';
  SYSTEM_NAMESPACES_COLLECTION = 'system.namespaces';
  SYSTEM_USERS = 'system.users';

  KEY_ID = '_id';
  KEY_USER = 'user';
  KEY_PASSWORD = 'pwd';
  KEY_READ_ONLY = 'readOnly';
  KEY_ERROR = 'err';

  GRIDFS_BUCKET_NAME = 'fs';
  GRIDFS_CHUNK_SIZE = 262144; //256KB
  GRIDFS_FIELD_FILE_NAME = 'filename';

type
  TListUtils = class
  private
  public
    class procedure FreeObjects(AList: TStringList);
  end;

  TGUIDUtils = class
  private
  public
    class function NewGuid: TGUID;overload;
    class function NewGuidAsString: String;overload;
    class function TryStringToGuid(value: String;var GUID: TGUID): Boolean;
  end;

  TMongoUtils = class
  public
    class function MakeHash(AUserName: String; APassword: String): String;
  end;

  TStringUtils = class
  public
    class function UTF8Encode(const AValue: WideString): UTF8String;
  end;

implementation

uses SysUtils, StrUtils, MongoMD5;

{ TListUtils }

class procedure TListUtils.FreeObjects(AList: TStringList);
var
  vObject: TObject;
  i: Integer;
begin
  for i := AList.Count-1 downto 0 do
  begin
    vObject := AList.Objects[i];

    FreeAndNil(vObject);
  end;
  AList.Clear;
end;

{ TGUIDUtils }

class function TGUIDUtils.NewGUID: TGUID;
begin
  if CreateGUID(Result) = E_NOTIMPL then
  begin
    raise Exception.CreateFmt('%s: Unable to create GUID.', [ClassName]);
  end;
end;

class function TGUIDUtils.NewGuidAsString: String;
begin
  Result := GuidToString(NewGuid);
end;

class function TGUIDUtils.TryStringToGuid(value: String;var GUID: TGUID): Boolean;
const
  GUID_LENGTH = 38;
begin
  Result := (LeftStr(value, 1) = '{') and (RightStr(value, 1) = '}') and (Length(value) = GUID_LENGTH);

  if Result then
  begin
    try
      GUID := StringToGuid(value);

      Result := True;
    except
      on E: EConvertError do
        Result := False
      else
        raise;
    end;
  end
end;

{ TMongoUtils }

class function TMongoUtils.MakeHash(AUserName, APassword: String): String;
begin
  Result := MD5(AUserName + ':mongo:' + APassword);
end;

{ TStringUtils }

class function TStringUtils.UTF8Encode(const AValue: WideString): UTF8String;
begin
  //because Linux is utf8 
  {$IFDEF MSWINDOWS}
  Result := System.UTF8Encode(AValue);
  {$ELSE}
  Result := AValue;  
  {$ENDIF}
end;

end.

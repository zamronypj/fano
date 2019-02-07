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
unit MongoMD5;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{ Uncomment to use indy 9}
{$DEFINE INDY_9}

interface

uses {$IFDEF FPC}MD5,{$ELSE}IdHashMessageDigest, idHash,{$ENDIF} SysUtils;

function MD5(value: String): String;

implementation

uses MongoUtils;

function MD5(value: String): String;
{$IFDEF FPC}
begin
  Result := LowerCase(MD5Print(MD5String(TStringUtils.UTF8Encode(value))));
end;
{$ELSE}
var
  vIdMD5: TIdHashMessageDigest5;
begin
  vIdMD5 := TIdHashMessageDigest5.Create;
  try
    {$IFDEF UNICODE} //Is the correct directive to use?
    Result := vIdMD5.HashStringAsHex(value, TEncoding.UTF8);
    {$ELSE}
      {$IFDEF INDY_9}
      Result := vIdMD5.AsHex(vIdMD5.HashValue(UTF8Encode(PAnsiChar(value))));
      {$ELSE}
      Result := vIdMD5.HashStringAsHex(UTF8Encode(PAnsiChar(value)));
      {$ENDIF}
    {$ENDIF}

    Result := LowerCase(Result);
  finally
    vIdMD5.Free;
  end;
end;
{$ENDIF}

end.

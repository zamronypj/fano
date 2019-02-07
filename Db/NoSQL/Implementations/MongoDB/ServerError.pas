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
unit ServerError;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses BSONTypes;

type
  TServerError = class
  private
  public
    class function GetErrorMessage(AObject: IBSONObject): String;
    class function GetErrorCode(AObject: IBSONObject): Integer;
    class function IsNotMasterError(AErrorCode: Integer; AErrorMessage: String): Boolean;
  end;

implementation

uses SysUtils;

{ TServerError }

class function TServerError.GetErrorCode(AObject: IBSONObject): Integer;
var
  vIndex: Integer;
begin
  Result := -1;

 if AObject.Find('code', vIndex) or
     AObject.Find('$code', vIndex) or
     AObject.Find('assertionCode', vIndex) then
  begin
    Result := AObject.Item[vIndex].AsInteger;
  end;
end;

class function TServerError.GetErrorMessage(AObject: IBSONObject): String;
var
  vIndex: Integer;
begin
  Result := EmptyStr;
  
  if AObject.Find('$err', vIndex) or
     AObject.Find('err', vIndex) or
     AObject.Find('errmsg', vIndex) then
  begin
    Result := AObject.Item[vIndex].AsString;
  end;
end;

class function TServerError.IsNotMasterError(AErrorCode: Integer; AErrorMessage: String): Boolean;
begin
  case AErrorCode of
    10054,
    10056,
    10058,
    10107,
    13435,
    13436: Result := True
  else
    Result := (Pos('not master', AErrorMessage) = 1);
  end;
end;

end.

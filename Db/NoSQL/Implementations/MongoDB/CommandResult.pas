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
unit CommandResult;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses BSONTypes, SysUtils;

type
  ICommandResult = interface(IBSONObject)
    ['{8F4C1FA8-5CD5-433A-A641-16DA896B42DB}']

    function Ok: Boolean;
    function HasError: Boolean;
    function GetCode: Integer;
    function GetErrorMessage: String;
    function GetException: Exception;
    procedure RaiseOnError;
  end;

implementation

end.

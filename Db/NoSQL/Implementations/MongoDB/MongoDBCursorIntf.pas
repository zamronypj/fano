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
unit MongoDBCursorIntf;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses BSONTypes;

type
  IMongoDBCursor = interface
    ['{BA92DC10-CEF6-440A-B7B1-1C1E4F79652B}']

    function Count: Integer;
    function Size: Integer;
    function Sort(AOrder: IBSONObject): IMongoDBCursor;
    function Hint(AIndexKeys: IBSONObject): IMongoDBCursor;overload;
    function Hint(AIndexName: String): IMongoDBCursor;overload;
    function Snapshot: IMongoDBCursor;
    function Explain: IBSONObject;
    function Limit(n: Integer): IMongoDBCursor;
    function Skip(n: Integer): IMongoDBCursor;
    function BatchSize(n: Integer): IMongoDBCursor;

    function HasNext: Boolean;
    function Next: IBSONObject;
  end;

implementation

end.

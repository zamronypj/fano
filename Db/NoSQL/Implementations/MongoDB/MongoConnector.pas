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
unit MongoConnector;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses MongoDB, MongoCollection, OutMessage, WriteConcern, WriteResult;

type
  IMongoConnector = interface
  ['{78A85A28-75DA-4F72-AC75-76F59327E073}']
//    procedure RequestStart;
//    procedure RequestDone;
//    procedure RequestEnsureConnection;

    function Send(ADB: TMongoDB; AOutMessage: IOutMessage; AConcern: IWriteConcern) : IWriteResult;
    //function Send(ADB: TMongoDB; AOutMessage: IOutMessage; AConcern: IWriteConcern; AHostNeeded: IServerAddress) : IWriteResult;

    //function call(ADB: TMongoDB; ACollection: TMongoCollection; AOutMessage: IOutMessage; ServerAddress hostNeeded, DBDecoder decoder ): Response;
    //function call(ADB: TMongoDB; ACollection: TMongoCollection; AOutMessage: IOutMessage; ServerAddress hostNeeded, Retries: Integer): Response;
    //function call(ADB: TMongoDB; ACollection: TMongoCollection; AOutMessage: IOutMessage; ServerAddress hostNeeded, Retries: Integer, ReadPreferences, DBDecoder decoder ): Response;

    function IsOpen: Boolean;
    
  end;

implementation

end.

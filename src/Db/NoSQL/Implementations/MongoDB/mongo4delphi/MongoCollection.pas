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
unit MongoCollection;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses MongoDBCursorIntf, BSONTypes, WriteResult, CommandResult, MongoUtils, MongoNotification;

type
  TMongoCollection = class(TObjectNotification)
  private
  protected
    function GetCollectionName: String;virtual;abstract;
    function GetFullName: String;virtual;abstract;
    function GetDBName: String;virtual;abstract;
  public
    property DBName: String read GetDBName;
    property CollectionName: String read GetCollectionName;
    property FullName: String read GetFullName;

    function Find: IMongoDBCursor;overload;virtual;abstract;
    function Find(Query: IBSONObject): IMongoDBCursor;overload;virtual;abstract;
    function Find(Query, Fields: IBSONObject): IMongoDBCursor;overload;virtual;abstract;

    function Count(Limit: Integer = 0): Integer;overload;virtual;abstract;
    function Count(Query: IBSONObject; Limit: Integer = 0): Integer;overload;virtual;abstract;

    function CreateIndex(KeyFields: IBSONObject; AIndexName: String = ''): IWriteResult;virtual;abstract;
    procedure DropIndex(AIndexName: String);virtual;abstract;
    procedure DropIndexes;virtual;abstract;

    procedure Drop();virtual;abstract;

    function Insert(const BSONObject: IBSONObject): IWriteResult;overload;virtual;abstract;
    function Insert(const BSONObjects: Array of IBSONObject): IWriteResult;overload;virtual;abstract;

    function Update(Query, BSONObject: IBSONObject): IWriteResult;overload;virtual;abstract;
    function Update(Query, BSONObject: IBSONObject; Upsert, Multi: Boolean): IWriteResult;overload;virtual;abstract;
    function UpdateMulti(Query, BSONObject: IBSONObject): IWriteResult;virtual;abstract;

    function Remove(AObject: IBSONObject): IWriteResult;virtual;abstract;

    function FindOne(): IBSONObject;overload;virtual;abstract;
    function FindOne(Query: IBSONObject): IBSONObject;overload;virtual;abstract;
    function FindOne(Query, Fields: IBSONObject): IBSONObject;overload;virtual;abstract;
                       
    function GetIndexInfo: IBSONArray;virtual;abstract;

    function Save(const BSONObject: IBSONObject): IWriteResult;
    function Distinct(AKey: String; const AQuery: IBSONObject = nil): IBSONObject;virtual;abstract;
    function Group(const AKey, AQuery, AInitial: IBSONObject; AReduce: String; AFinalize: String = ''): IBSONObject;virtual;abstract;
  end;

implementation

{ TMongoCollection }

function TMongoCollection.Save(const BSONObject: IBSONObject): IWriteResult;
var
  vQuery: IBSONObject;
begin
  if (not BSONObject.HasOid) or (BSONObject.HasOid and BSONObject.GetOid.IsNew) then
  begin
    Result := Insert(BSONObject);
  end
  else
  begin
    vQuery := TBSONObject.NewFrom(KEY_ID, BSONObject.GetOid.OID);

    Result := Update(vQuery, BSONObject);
  end;
end;

end.

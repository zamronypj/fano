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
unit MongoCollectionApiLayer;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses MongoDBCursorIntf, BSONTypes, WriteResult, CommandResult, MongoDB, MongoCollection,
     MongoConnector, MongoProvider, MongoUtils, Classes;

type
  TMongoCollectionApiLayer = class(TMongoCollection)
  private
    FMongoDatabase: TMongoDB;
    FCollectionName: String;
    FConnector: IMongoConnector;
    FProvider: IMongoProvider;

    function GenerateIndexName(KeyFields: IBSONObject): String;
  protected
    function GetCollectionName: String;override;
    function GetDBName: String;override;
    function GetFullName: String;override;
  public
    constructor Create(AMongoDB: TMongoDB; ACollectionName: String; AConnector: IMongoConnector; AProvider: IMongoProvider);
    destructor Destroy; override;

    function Count(Limit: Integer = 0): Integer;overload;override;
    function Count(Query: IBSONObject; Limit: Integer = 0): Integer;overload;override;

    function CreateIndex(KeyFields: IBSONObject; AIndexName: String): IWriteResult;override;
    procedure Drop;override;
    procedure DropIndex(AIndexName: String);override;
    procedure DropIndexes;override;

    function Find: IMongoDBCursor;overload;override;
    function Find(Query: IBSONObject): IMongoDBCursor;overload;override;
    function Find(Query, Fields: IBSONObject): IMongoDBCursor;overload;override;

    function FindOne(): IBSONObject;overload;override;
    function FindOne(Query: IBSONObject): IBSONObject;overload;override;
    function FindOne(Query, Fields: IBSONObject): IBSONObject;overload;override;

    function GetIndexInfo: IBSONArray;override;

    function Insert(const BSONObject: IBSONObject): IWriteResult;overload;override;
    function Insert(const BSONObjects: Array of IBSONObject): IWriteResult;overload;override;

    function Remove(AObject: IBSONObject): IWriteResult;override;

    function Update(Query, BSONObject: IBSONObject): IWriteResult;overload;override;
    function Update(Query, BSONObject: IBSONObject; Upsert, Multi: Boolean): IWriteResult;overload;override;
    function UpdateMulti(Query, BSONObject: IBSONObject): IWriteResult;override;

    function Distinct(AKey: String; const AQuery: IBSONObject = nil): IBSONObject;override;
    function Group(const AKey, AQuery, AInitial: IBSONObject; AReduce: String; AFinalize: String = ''): IBSONObject;override;
  end;


implementation

uses SysUtils, MongoDBCursor;

{ TMongoCollectionApiLayer }

function TMongoCollectionApiLayer.Count(Limit: Integer): Integer;
begin
  Result := Count(TBSONObject.Empty, Limit);
end;

function TMongoCollectionApiLayer.Count(Query: IBSONObject; Limit: Integer): Integer;
var
  vCommand: IBSONObject;
  vCommandResult: ICommandResult;
  vErrorMessage: String;
begin
  Result := 0;

  vCommand := TBSONObject.NewFrom('count', FCollectionName);
  vCommand.Put('query', Query);

  if Limit > 0 then
    vCommand.Put('limit', Limit);

  vCommandResult := FMongoDatabase.RunCommand(vCommand);

  if (not vCommandResult.Ok) or vCommandResult.HasError then
  begin
    vErrorMessage := vCommandResult.GetErrorMessage();

    if SameText(vErrorMessage, 'ns does not exist') or
       SameText(vErrorMessage, 'ns missing') then
      Result := 0 // for now, return 0 - lets pretend it does exist
    else
      vCommandResult.RaiseOnError();
  end
  else
    Result := vCommandResult.Items['n'].AsInteger;
end;

function TMongoCollectionApiLayer.CreateIndex(KeyFields: IBSONObject; AIndexName: String): IWriteResult;
begin
  if (Trim(AIndexName) = EmptyStr) then
  begin
    AIndexName := GenerateIndexName(KeyFields); 
  end;

  Result :=fProvider.CreateIndex(FMongoDatabase.DBName, FCollectionName, KeyFields, AIndexName);
end;

procedure TMongoCollectionApiLayer.Drop;
begin
  FProvider.RunCommand(FMongoDatabase.DBName, TBSONObject.NewFrom('drop', FCollectionName));
end;

function TMongoCollectionApiLayer.Find: IMongoDBCursor;
begin
  Result := Find(TBSONObject.Create as IBSONObject);
end;

function TMongoCollectionApiLayer.Find(Query: IBSONObject): IMongoDBCursor;
begin
  Result := Find(Query, TBSONObject.Create as IBSONObject);
end;

procedure TMongoCollectionApiLayer.DropIndex(AIndexName: String);
var
  vCommand: IBSONObject;
  vCommandResult: ICommandResult;
begin
  vCommand := TBSONObject.NewFrom('deleteIndexes', FCollectionName)
                         .Put('index' , AIndexName);

  //TODO - Cache of EnsureIndex
  //ResetIndexCache();

  vCommandResult := FMongoDatabase.RunCommand(vCommand);

  if (not vCommandResult.Ok) or
     (not SameText(vCommandResult.GetErrorMessage, 'ns not found')) then
  begin
    vCommandResult.RaiseOnError;
  end;
end;

function TMongoCollectionApiLayer.Find(Query, Fields: IBSONObject): IMongoDBCursor;
begin
  Result := TMongoDBCursor.Create(Self, Query, Fields, FConnector, FProvider);
end;

function TMongoCollectionApiLayer.GetFullName: String;
begin
  Result := FMongoDatabase.DBName + '.' + FCollectionName;
end;

function TMongoCollectionApiLayer.GenerateIndexName(KeyFields: IBSONObject): String;
var
  i: Integer;
  vIndexName: String;
begin
  vIndexName := 'idx';

  for i := 0 to KeyFields.Count-1 do
  begin
    vIndexName := vIndexName + '_' + KeyFields[i].Name;
  end;

  Result := vIndexName;
end;

function TMongoCollectionApiLayer.Insert(const BSONObject: IBSONObject): IWriteResult;
begin
  Result := FProvider.Insert(FMongoDatabase.DBName, FCollectionName, BSONObject);
end;

function TMongoCollectionApiLayer.Insert(const BSONObjects: array of IBSONObject): IWriteResult;
begin
  Result := FProvider.Insert(FMongoDatabase.DBName, FCollectionName, BSONObjects);
end;

function TMongoCollectionApiLayer.Remove(AObject: IBSONObject): IWriteResult;
begin
  Result := FProvider.Remove(FMongoDatabase.DBName, FCollectionName, AObject);
end;

function TMongoCollectionApiLayer.Update(Query, BSONObject: IBSONObject): IWriteResult;
begin
  Result := FProvider.Update(FMongoDatabase.DBName, FCollectionName, Query, BSONObject);
end;

function TMongoCollectionApiLayer.Update(Query, BSONObject: IBSONObject; Upsert, Multi: Boolean): IWriteResult;
begin
  Result := FProvider.Update(FMongoDatabase.DBName, FCollectionName, Query, BSONObject, Upsert, Multi);
end;

function TMongoCollectionApiLayer.UpdateMulti(Query,BSONObject: IBSONObject): IWriteResult;
begin
  Result := FProvider.UpdateMulti(FMongoDatabase.DBName, FCollectionName, Query, BSONObject);
end;

function TMongoCollectionApiLayer.FindOne: IBSONObject;
begin
  Result := FProvider.FindOne(FMongoDatabase.DBName, FCollectionName);
end;                        

function TMongoCollectionApiLayer.FindOne(Query: IBSONObject): IBSONObject;
begin
  Result := FProvider.FindOne(FMongoDatabase.DBName, FCollectionName, Query);
end;

function TMongoCollectionApiLayer.FindOne(Query, Fields: IBSONObject): IBSONObject;
begin
  Result := FProvider.FindOne(FMongoDatabase.DBName, FCollectionName, Query, Fields);
end;

function TMongoCollectionApiLayer.GetIndexInfo: IBSONArray;
var
  vCommand: IBSONObject;
  vCursor: IMongoDBCursor;
begin
  Result := TBSONArray.Create;

  vCommand := TBSONObject.NewFrom('ns', FullName);

  vCursor := FMongoDatabase.GetCollection(SYSTEM_INDEXES_COLLECTION).Find(vCommand);

  while (vCursor.HasNext) do
  begin
    Result.Put(vCursor.Next);
  end;
end;

procedure TMongoCollectionApiLayer.DropIndexes;
begin
  DropIndex('*');
end;


function TMongoCollectionApiLayer.GetCollectionName: String;
begin
  Result := FCollectionName;
end;

constructor TMongoCollectionApiLayer.Create(AMongoDB: TMongoDB; ACollectionName: String; AConnector: IMongoConnector; AProvider: IMongoProvider);
begin
  inherited Create;
  FMongoDatabase := AMongoDB;
  FCollectionName := ACollectionName;
  FConnector := AConnector;
  FProvider := AProvider; 
end;

function TMongoCollectionApiLayer.GetDBName: String;
begin
  Result := FMongoDatabase.DBName;
end;

destructor TMongoCollectionApiLayer.Destroy;
begin
  inherited;
end;

function TMongoCollectionApiLayer.Distinct(AKey: String; const AQuery: IBSONObject): IBSONObject;
var
  vCommand: IBSONObject;
  vCommandResult: ICommandResult;
begin
  vCommand := TBSONObject.NewFrom('distinct', FCollectionName).Put('key', AKey);

  if AQuery <> nil then
  begin
    vCommand.Put('query', AQuery);
  end;

  vCommandResult := FMongoDatabase.RunCommand(vCommand);

  Result := vCommandResult.Items['Values'].AsBSONObject;
end;

function TMongoCollectionApiLayer.Group(const AKey, AQuery, AInitial: IBSONObject; AReduce: String; AFinalize: String): IBSONObject;
var
  vGroup: IBSONObject;
begin
  vGroup := TBSONObject.NewFrom('ns', FCollectionName)
                       .Put('key', AKey)
                       .Put('$reduce', AReduce)
                       .Put('initial', AInitial);

  if AQuery <> nil then
  begin
    vGroup.Put('cond', AQuery);
  end;

  if (AFinalize <> '') then
  begin
    vGroup.Put('finalize', AFinalize);
  end;

  Result := FMongoDatabase.RunCommand(TBSONObject.NewFrom('group', vGroup)).Items['retval'].AsBSONObject;
end;

end.

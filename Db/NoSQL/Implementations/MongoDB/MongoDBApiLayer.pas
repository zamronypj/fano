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
unit MongoDBApiLayer;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses Mongo, MongoDB, Contnrs, MongoConnector, MongoProvider, BSONTypes,
     MongoCollection, CommandResult, MongoUtils, Classes;

type
  TMongoDBApiLayer = class(TMongoDB)
  private
    FMongo: TMongo;
    FDBName: String;
    FConnector: IMongoConnector;
    FProvider: IMongoProvider;
    FCollectionList: TObjectList;

    function DoGetCollections(AIncludeSystemCollections: Boolean): IBSONObject;
    procedure OnFreeCollection(Sender: TObject);
  protected
    function GetDBName: String;override;
  public
    constructor Create(AMongo: TMongo; ADBName: String; AConnector: IMongoConnector; AProvider: IMongoProvider);
    destructor Destroy; override;

    function Authenticate(AUserName: String; APassword: String): Boolean;override;
    procedure Logout;override;

    function CreateCollection(AName: String; AOptions: IBSONObject): TMongoCollection;override;

    procedure DropCollection(AName: String);override;

    function GetCollection(AName: String): TMongoCollection;override;
    function GetCollections: IBSONObject;override;

    function GetLastError: ICommandResult;override;
    function GetUserCollections: IBSONObject;override;

    function RunCommand(ACommand: IBSONObject): ICommandResult;override;
  end;

implementation

uses MongoCollectionApiLayer, MongoDBCursorIntf, StrUtils;

{ TMongoDBApiLayer }

function TMongoDBApiLayer.Authenticate(AUserName, APassword: String): Boolean;
begin
  Result := FProvider.Authenticate(FDBName, AUserName, APassword);
end;

constructor TMongoDBApiLayer.Create(AMongo: TMongo; ADBName: String; AConnector: IMongoConnector; AProvider: IMongoProvider);
begin
  inherited Create;
  FMongo := AMongo;
  FDBName := ADBName;
  FConnector := AConnector;
  FProvider := AProvider;
  
  FCollectionList := TObjectList.Create;
end;

function TMongoDBApiLayer.CreateCollection(AName: String; AOptions: IBSONObject): TMongoCollection;
var
  vCommand: IBSONObject;
  vCommandResult: ICommandResult;
begin
  if Assigned(AOptions) and (AOptions.Count > 0) then
  begin
    vCommand := TBSONObject.NewFrom('create', AName);
    vCommand.PutAll(AOptions);

    vCommandResult := FProvider.RunCommand(FDBName, vCommand);
    vCommandResult.RaiseOnError();
  end;

  Result := GetCollection(AName);
end;

destructor TMongoDBApiLayer.Destroy;
var
  i: Integer;
begin
  for i := 0 to FCollectionList.Count-1 do
  begin
    TMongoCollection(FCollectionList[i]).RemoveFreeNotification;
  end;
  FProvider := nil;
  FConnector := nil;
  FCollectionList.Free;

  inherited;
end;

procedure TMongoDBApiLayer.DropCollection(AName: String);
begin
  FProvider.RunCommand(FDBName, TBSONObject.NewFrom('drop', AName));
end;

function TMongoDBApiLayer.GetCollection(AName: String): TMongoCollection;
begin
  Result := TMongoCollectionApiLayer.Create(Self, AName, FConnector, FProvider);
  Result.FreeNotification(OnFreeCollection);

  FCollectionList.Add(Result);
end;

function TMongoDBApiLayer.GetDBName: String;
begin
  Result := FDBName;
end;

function TMongoDBApiLayer.GetLastError: ICommandResult;
begin
  Result := FProvider.GetLastError(FDBName);
end;

function TMongoDBApiLayer.GetCollections: IBSONObject;
begin
  Result := DoGetCollections(True);
end;

function TMongoDBApiLayer.GetUserCollections: IBSONObject;
begin
  Result := DoGetCollections(False);
end;

function TMongoDBApiLayer.DoGetCollections(AIncludeSystemCollections: Boolean): IBSONObject;
var
  vNamespaces: TMongoCollection;
  vCursor: IMongoDBCursor;
  vNS: IBSONObject;
  vPosDot: Integer;
  vDBName,
  vFullName,
  vCollection: String;
begin
  Result := TBSONObject.Create;

  vNamespaces := GetCollection(SYSTEM_NAMESPACES_COLLECTION);

  vCursor := vNamespaces.Find;

  while vCursor.HasNext do
  begin
    vNS := vCursor.Next;

    vFullName := vNS.Items['name'].AsString;

    vPosDot := Pos('.', vFullName);

    vDBName := LeftStr(vFullName, vPosDot-1);

    if (vDBName = FDBName) and not AnsiContainsStr(vFullName, '$') then
    begin
      vCollection := Copy(vFullName, vPosDot+1, MaxInt);

      if not AIncludeSystemCollections and (Pos('system', vCollection) = 1) then
        Continue;

      Result.Put('name', vCollection);
    end;
  end;
end;

procedure TMongoDBApiLayer.Logout;
begin
  FProvider.RunCommand(FDBName, TBSONObject.NewFrom('logout', 1));
end;

procedure TMongoDBApiLayer.OnFreeCollection(Sender: TObject);
begin
  FCollectionList.OwnsObjects := False;
  try
    FCollectionList.Remove(Sender);
  finally
    FCollectionList.OwnsObjects := True;
  end;
end;

function TMongoDBApiLayer.RunCommand(ACommand: IBSONObject): ICommandResult;
begin
  Result := FProvider.RunCommand(FDBName, ACommand);
end;

end.

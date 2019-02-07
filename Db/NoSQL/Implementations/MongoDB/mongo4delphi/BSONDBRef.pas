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
unit BSONDBRef;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses BsonTypes, MongoDB;

type
  TBSONDBRef = class(TBSONObject, IBSONDBRef)
  private
    FObjectId: IBSONObjectId;
    FDB: String;
    FCollection: String;
    FRefDoc: IBSONObject;
    function GetCollection: String;
    function GetDB: String;
    function GetObjectId: IBSONObjectId;
  public
    property DB: String read GetDB;
    property Collection: String read GetCollection;
    property ObjectId: IBSONObjectId read GetObjectId;

    constructor Create(const ADB, ACollection: String; const AObjectId: IBSONObjectId);

    class function NewFrom(const ADB, ACollection: String; const AObjectId: IBSONObjectId): IBSONDBRef;

    class function Fetch(ADB: TMongoDB; ARef: IBSONDBRef): IBSONObject;overload;
    class function Fetch(ADB: TMongoDB; AQuery: IBSONObject): IBSONObject;overload;

    function GetInstance: TObject;
  end;

implementation

uses SysUtils, MongoUtils,
  MongoException;

{ TBSONDBRef }

constructor TBSONDBRef.Create(const ADB, ACollection: String; const AObjectId: IBSONObjectId);
begin
  inherited Create;
  FDB := ADB;
  FCollection := ACollection;
  FObjectId := AObjectId;
end;

class function TBSONDBRef.Fetch(ADB: TMongoDB; ARef: IBSONDBRef): IBSONObject;
begin
  with TBSONDBRef(ARef.GetInstance) do
  begin
    if (FRefDoc = nil) then
    begin
      if (ADB.DBName <> ARef.DB) then
        raise EMongoDBNotEquals.Create('Must use same db.');

      FRefDoc := ADB.GetCollection(ARef.Collection).FindOne(TBSONObject.NewFrom(KEY_ID, ARef.ObjectId));
    end;

    Result := FRefDoc;
  end;
end;

class function TBSONDBRef.Fetch(ADB: TMongoDB;AQuery: IBSONObject): IBSONObject;
var
  vIndexRef, vIndexId: Integer;
begin
  Result := nil;

  if AQuery.Find('$ref', vIndexRef) and AQuery.Find('$id', vIndexId) then
  begin
    Result := ADB.GetCollection(AQuery.Item[vIndexRef].AsString).FindOne(TBSONObject.NewFrom(KEY_ID, AQuery.Item[vIndexId].AsString));
  end;
end;

function TBSONDBRef.GetCollection: String;
begin
  Result := FCollection;
end;

function TBSONDBRef.GetDB: String;
begin
  Result := FDB;
end;

function TBSONDBRef.GetInstance: TObject;
begin
  Result := Self; 
end;

function TBSONDBRef.GetObjectId: IBSONObjectId;
begin
  Result := FObjectId;
end;

class function TBSONDBRef.NewFrom(const ADB, ACollection: String; const AObjectId: IBSONObjectId): IBSONDBRef;
begin
  Result := TBSONDBRef.Create(ADB, ACollection, AObjectId);
end;


end.

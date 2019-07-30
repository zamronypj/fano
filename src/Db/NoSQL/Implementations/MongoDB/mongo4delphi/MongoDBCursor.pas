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
unit MongoDBCursor;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses MongoDBCursorIntf, BSONTypes, MongoCollection, BSONStream, MongoException,
     MongoConnector, MongoProvider;

type
  TMongoDBCursor = class(TInterfacedObject, IMongoDBCursor)
  private
    FCollection: TMongoCollection;
    FQuery: IBSONObject;
    FFields: IBSONObject;
    FBatchSize: Integer;
    FLimit: Integer;
    FSkip: Integer;
    FOrderBy: IBSONObject;
    FExplain: Boolean;
    FSnapShot: Boolean;
    FRequestId: Integer;
    FNumberReturned: Integer;
    FFetchedRecords: Integer;
    FTotalRecordsReturned: Integer;
    FStream: TBSONStream;
    FCursorId: Int64;
    FSavedCursorId: Int64;
    FIndexName: String;
    FIndexKeys: IBSONObject;
    FConnector: IMongoConnector;
    FProvider: IMongoProvider;

    procedure OpenCursor;

    procedure AssertCursorIsNotOpen;

    function Clone: TMongoDBCursor;

    function ChooseBatchSize(batchSize, limit, fetched: Integer): Integer;

    procedure KillOpenedCursor;
  public
    constructor Create(ACollection: TMongoCollection; AQuery: IBSONObject; AFields: IBSONObject; AConnector: IMongoConnector; AProvider: IMongoProvider);
    destructor Destroy; override;

    //does not consider the limit
    function Count: Integer;

    //consider the Limit
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

uses Math, SysUtils, MongoDecoder;

{ TMongoDBCursor }

procedure TMongoDBCursor.AssertCursorIsNotOpen;
begin
  if (FRequestId > 0) then
    raise EMongoDBCursorStateException.CreateRes(@sMongoDBCursorStateException);
end;

function TMongoDBCursor.BatchSize(n: Integer): IMongoDBCursor;
begin
  AssertCursorIsNotOpen;

  //Java driver documented a server bug with batchsize 1 
  if (n = 1) then
    n := 2;

  FBatchSize := n;

  Result := Self; 
end;

function TMongoDBCursor.ChooseBatchSize(batchSize, limit, fetched: Integer): Integer;
var
  bs: Integer;
  remaining: Integer;
  res: Integer;
begin
  bs := abs(batchSize);
  remaining := IfThen(limit > 0, limit - fetched, 0);
  if (bs = 0) and (remaining > 0) then
    res := remaining
  else if (bs > 0) and (remaining = 0) then
    res := bs
  else
    res := Min(bs, remaining);

  if (batchSize < 0) then
      res := res * (-1); // force close

  if (res = 1) then
      res := -1; // optimization: use negative batchsize to close cursor
      
  Result := res;
end;

function TMongoDBCursor.Clone: TMongoDBCursor;
var
  vClone: TMongoDBCursor;
begin
  vClone := TMongoDBCursor.Create(FCollection, FQuery, FFields, FConnector, FProvider);
  vClone.FBatchSize := FBatchSize;
  vClone.FLimit:= FLimit;
  vClone.FSkip:= FSkip;
  vClone.FOrderBy:= FOrderBy;
  vClone.FExplain := FExplain;
  vClone.FSnapShot := FSnapShot;
  vClone.FIndexName := FIndexName;
  vClone.FIndexKeys := FIndexKeys;

  Result := vClone;
end;

function TMongoDBCursor.Count: Integer;
begin
  Result := FCollection.Count(FQuery);
end;

constructor TMongoDBCursor.Create(ACollection: TMongoCollection; AQuery, AFields: IBSONObject; AConnector: IMongoConnector; AProvider: IMongoProvider);
begin
  inherited Create;
  FStream := TBSONStream.Create;
  FCollection := ACollection;
  FQuery := AQuery;
  FFields := AFields;
  FConnector := AConnector;
  FProvider := AProvider;
end;

destructor TMongoDBCursor.Destroy;
begin
  KillOpenedCursor;
  
  FStream.Free;
  inherited;
end;

function TMongoDBCursor.Explain: IBSONObject;
var
  vClone: TMongoDBCursor;
begin
  vClone := Clone;
  try
    vClone.FExplain := True;

    if (vClone.FLimit > 0) then
    begin
      //need to pass a negative batchSize as limit for explain
      vClone.FBatchSize := vClone.FLimit * (-1);
      vClone.FLimit := 0;
    end;

    Result := vClone.Next;
  finally
    vClone.Free;
  end;
end;

procedure TMongoDBCursor.OpenCursor;
var
  vQuery: IBSONObject;
  vResponse: IBSONObject;
begin
  if (FRequestId > 0) then Exit;

  vQuery := TBSONObject.Create;
  vQuery.Put('query', FQuery);
  if Assigned(FOrderBy) then
  begin
    vQuery.Put('orderby', FOrderBy);
  end;

  if (Trim(FIndexName) <> EmptyStr) then
    vQuery.Put('$hint', FIndexName);
  if (FIndexKeys <> nil) then
    vQuery.Put('$hint', FIndexKeys);

  if (FExplain) then
    vQuery.Put('$explain', True);

  if (FSnapShot) then
    vQuery.Put('$snapshot', True);

  vResponse := FProvider.OpenQuery(FStream, FCollection.DBName, FCollection.CollectionName, vQuery, FFields, FSkip, ChooseBatchSize(FBatchSize, FLimit, 0));
  FRequestId := vResponse.Items['requestId'].AsInteger;
  FNumberReturned := vResponse.Items['numberReturned'].AsInteger;
  FCursorId := vResponse.Items['cursorId'].AsInt64;
  FSavedCursorId := FCursorId;
end;

function TMongoDBCursor.HasNext: Boolean;
var
  vResponse: IBSONObject;
begin
  OpenCursor;

  if (FLimit > 0) and (FTotalRecordsReturned >= FLimit) then
    Result := False
  else if (FFetchedRecords < FNumberReturned) then
    Result := True
  else
  begin
    vResponse := FProvider.HasNext(FStream, FCollection.DBName, FCollection.CollectionName, FCursorId, ChooseBatchSize(FBatchSize, FLimit, FTotalRecordsReturned));
    FRequestId := vResponse.Items['requestId'].AsInteger;
    FNumberReturned := vResponse.Items['numberReturned'].AsInteger;
    FCursorId := vResponse.Items['cursorId'].AsInt64;

    FFetchedRecords := 0;

    Result := vResponse.Items['hasNext'].AsBoolean;
  end;
end;

function TMongoDBCursor.Next: IBSONObject;
begin
  OpenCursor;

  Result := TMongoDecoderFactory.DefaultDecoder.Decode(FStream);

  Inc(FFetchedRecords);
  Inc(FTotalRecordsReturned);
end;

function TMongoDBCursor.Limit(n: Integer): IMongoDBCursor;
begin
  AssertCursorIsNotOpen;

  FLimit := n;

  Result := Self;
end;

function TMongoDBCursor.Size: Integer;
begin
  Result := FCollection.Count(FQuery, FLimit);
end;

function TMongoDBCursor.Skip(n: Integer): IMongoDBCursor;
begin
  AssertCursorIsNotOpen;

  FSkip := n;

  Result := Self;
end;

function TMongoDBCursor.Snapshot: IMongoDBCursor;
begin
  AssertCursorIsNotOpen;

  FSnapShot := True;

  Result := Self;
end;

function TMongoDBCursor.Sort(AOrder: IBSONObject): IMongoDBCursor;
begin
  AssertCursorIsNotOpen;

  FOrderBy := AOrder;

  Result := Self;
end;

procedure TMongoDBCursor.KillOpenedCursor;
begin
  if FSavedCursorId > 0 then
  begin
    FProvider.KillCursor(FSavedCursorId);
  end;
end;

function TMongoDBCursor.Hint(AIndexName: String): IMongoDBCursor;
begin
  AssertCursorIsNotOpen;

  FIndexName := AIndexName;

  Result := Self;
end;

function TMongoDBCursor.Hint(AIndexKeys: IBSONObject): IMongoDBCursor;
begin
  AssertCursorIsNotOpen;

  FIndexKeys := AIndexKeys;
  
  Result := Self;
end;

end.

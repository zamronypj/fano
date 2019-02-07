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
unit GridFS;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses MongoDB, MongoCollection, BSONTypes, MongoUtils, Classes;

type
  TGridFS = class;
  TGridFSFile = class;

  IGridFSFile = interface(IBSONObject)
  ['{948F40E2-9D30-44D4-8C97-916C049714CE}']
    function GetLength: Integer;
    function GetChunkSize: Integer;
    function GetFileName: String;
    function GetContentType: String;
    function GetUploadDate: TDateTime;
    function GetMD5: String;

    function numChunks: Integer;

    function GetInputStream: TStream;
    function GetChunkData(const AChunkNum: Integer): IBSONBinary;

    function SetContentType(AContentType: String): IGridFSFile;
    function SetChunkSize(AChunkSize: Integer): IGridFSFile;

    procedure Store(AStream: TStream);

    function Put(const AKey: String; Value: Variant): IGridFSFile;
  end;

  TGridFS = class
  private
    FDB: TMongoDB;
    FChunksCollection: TMongoCollection;
    FFilesCollection: TMongoCollection;
    FBucketName: String;

    function VerifyResult(const ABSONObject: IBSONObject): IGridFSFile;
  public
    constructor Create(ADB: TMongoDB);overload;
    constructor Create(ADB: TMongoDB; ABucketName: String);overload;

    function CreateFile(AFileName: String): IGridFSFile;

    function findOne(const AFileName: String): IGridFSFile;overload;
    function findOne(const AQuery: IBSONObject): IGridFSFile;overload;

    procedure Remove(const AObjectId: IBSONObjectId);
  end;
    
  TGridFSFile = class(TBSONObject, IGridFSFile)
  private
    FLength: Integer;
    FChunkSize: Integer;
    FId: IBSONObjectId;
    FFileName: String;
    FContentType: String;
    FUploadDate: TDateTime;
    FMD5: String;
    FExtraData: IBSONObject;
    FGridFS: TGridFS;
  protected
    procedure PushItem(AIndex: Integer; AItem: TBSONItem); override;
  public
    function GetLength: Integer;
    function GetChunkSize: Integer;
    function GetOid: IBSONObjectId;
    function GetFileName: String;
    function GetContentType: String;
    function GetUploadDate: TDateTime;
    function GetMD5: String;

    function numChunks: Integer;

    constructor Create(AGridFS: TGridFS);overload;
    constructor Create(AGridFS: TGridFS; const AFileName: String);overload;
    procedure AfterConstruction; override;

    function GetInputStream: TStream;

    function GetChunkData(const AChunkNum: Integer): IBSONBinary;

    function SetChunkSize(AChunkSize: Integer): IGridFSFile;
    function SetContentType(AContentType: String): IGridFSFile;

    procedure Store(AStream: TStream);

    function Put(const AKey: String; Value: Variant): IGridFSFile;overload;
  end;

implementation

uses SysUtils, Math, MongoException;

type
  TGridFsFileStreamReader = class(TMemoryStream)
  private
    FGridFsFile: TGridFSFile;
    FNumChunks: Integer;
    FCurrentChunk: Integer;
    FCurrentChunkData: IBSONBinary;

    function Avaliable: Integer;

    function InternalRead(Count, FromPosition: Integer): Integer;
  public
    constructor Create(AGridFsFile: TGridFSFile);

    function Read(var Buffer; Count: Integer): Integer; override;
  end;

  TGridFSFileWriter = class
  private
  public
    procedure Store(const AFile: TGridFSFile; AStream: TStream);
  end;

{ TGridFS }

constructor TGridFS.Create(ADB: TMongoDB);
begin
  Create(ADB, GRIDFS_BUCKET_NAME);
end;

constructor TGridFS.Create(ADB: TMongoDB; ABucketName: String);
begin
  FDB := ADB;
  FBucketName := ABucketName;

  FFilesCollection := FDB.GetCollection(FBucketName + '.files');
  FChunksCollection := FDB.GetCollection(FBucketName + '.chunks');
end;

function TGridFS.CreateFile(AFileName: String): IGridFSFile;
begin
  Result := TGridFSFile.Create(Self, AFileName);
end;

function TGridFS.findOne(const AFileName: String): IGridFSFile;
begin
  Result := findOne(TBSONObject.NewFrom(GRIDFS_FIELD_FILE_NAME, AFileName) as IBSONObject);
end;

function TGridFS.findOne(const AQuery: IBSONObject): IGridFSFile;
begin
  Result := VerifyResult(FFilesCollection.FindOne(AQuery));
end;

procedure TGridFS.Remove(const AObjectId: IBSONObjectId);
begin
  FFilesCollection.Remove(TBSONObject.NewFrom(KEY_ID, AObjectId));
  FChunksCollection.Remove(TBSONObject.NewFrom('files_id', AObjectId));  
end;

function TGridFS.VerifyResult(const ABSONObject: IBSONObject): IGridFSFile;
begin
  Result := nil;

  if Assigned(ABSONObject) then
  begin
    Result := TGridFSFile.Create(Self);
    Result.PutAll(ABSONObject);
  end;
  (*
  if not Supports(ABSONObject, IGridFsFile, Result) then
  begin
    raise EBSONTypesException.CreateRes(@sNotAGridFSObject);
  end;
  *)
end;

{ TGridFSFileWriter }

procedure TGridFSFileWriter.Store(const AFile: TGridFSFile; AStream: TStream);
var
  vFile: IBSONObject;
  vChunkNumber: Integer;
  vData: IBSONBinary;
begin
  AFile.FLength := AStream.Size;

  if not AFile.Contain('uploadDate') then
  begin
    AFile.Put('uploadDate', Now);
  end;

  if not AFile.HasOid then
  begin
    AFile.Put(KEY_ID, TBSONObjectId.NewFrom);
  end;

  if AFile.GetMD5 <> EmptyStr then
  begin
//    vFile.Put('md5', MakeHash);
  end;

  vFile := TBSONObject.EMPTY.PutAll(AFile.FExtraData)
                      .Put('length', AFile.GetLength)
                      .Put('uploadDate', Now)
                      .Put('filename', AFile.GetFileName)
                      .Put('contentType', AFile.GetContentType)
                      .Put('chunkSize', AFile.GetChunkSize)
                      .Put('uploadDate', AFile.GetUploadDate)
//                      .Put('md5', AFile.GetMD5)
                      .Put(KEY_ID, AFile.GetOid);

  AFile.FGridFS.FFilesCollection.Insert(vFile);

  AStream.Position := 0;

  vChunkNumber := 0;

  while (AStream.Position < AStream.Size) do
  begin
    vData := TBSONBinary.Create();
    vData.CopyFrom(AStream, Min(AStream.Size - AStream.Position, AFile.GetChunkSize));

    AFile.FGridFS.FChunksCollection.Insert(TBSONObject.NewFrom('files_id', vFile.GetOid)
                                                .Put('n', vChunkNumber)
                                                .Put('data', vData));

    Inc(vChunkNumber);
  end;
end;

{ TGridFSFile }

procedure TGridFSFile.AfterConstruction;
begin
  inherited;
  FExtraData := TBSONObject.EMPTY;
end;

constructor TGridFSFile.Create(AGridFS: TGridFS; const AFileName: String);
begin
  inherited Create;
  FGridFS := AGridFS;
  FFileName := AFileName;
  FChunkSize := GRIDFS_CHUNK_SIZE;
end;

constructor TGridFSFile.Create(AGridFS: TGridFS);
begin
  Self.Create(AGridFS, EmptyStr);
end;

function TGridFSFile.GetChunkData(const AChunkNum: Integer): IBSONBinary;
var
  vChunk: IBSONObject;
begin
  vChunk := FGridFS.FChunksCollection.FindOne(TBSONObject.NewFrom('files_id', FId).Put('n', AChunkNum));

//        if ( chunk == null )
//            throw new MongoException( "can't find a chunk!  file id: " + _id + " chunk: " + i );
  Result := vChunk.Items['data'].AsBSONBinary;
  Result.Stream.Position := 0;
end;

function TGridFSFile.GetChunkSize: Integer;
begin
  Result := FChunkSize;
end;

function TGridFSFile.GetContentType: String;
begin
  Result := FContentType;
end;

function TGridFSFile.GetFileName: String;
begin
  Result := FFileName;
end;

function TGridFSFile.GetInputStream: TStream;
begin
  Result := TGridFsFileStreamReader.Create(Self);
end;

function TGridFSFile.GetLength: Integer;
begin
  Result := FLength;
end;

function TGridFSFile.GetMD5: String;
begin
  Result := FMD5;
end;

function TGridFSFile.GetOid: IBSONObjectId;
begin
  Result := FId;
end;

function TGridFSFile.GetUploadDate: TDateTime;
begin
  Result := FUploadDate;
end;

function TGridFSFile.numChunks: Integer;
begin
  Result := Ceil(FLength / FChunkSize);
end;

procedure TGridFSFile.PushItem(AIndex: Integer; AItem: TBSONItem);
begin
  if AItem.Name = '_id' then
    FId := TBSONObjectId.NewFromOID(AItem.AsObjectId.OID)
  else if AItem.Name = 'filename' then
    FFileName := AItem.AsString
  else if AItem.Name = 'contentType' then
    FContentType := AItem.AsString
  else if AItem.Name = 'length' then
    FLength := AItem.AsInteger
  else if AItem.Name = 'chunkSize' then
    FChunkSize := AItem.AsInteger
  else if AItem.Name = 'uploadDate' then
    FUploadDate := AItem.AsDateTime
  else if AItem.Name = 'md5' then
    FMD5 := AItem.AsString
  else
    FExtraData.Put(AItem.Name, AItem.Value);

  AItem.Free;
end;


function TGridFSFile.Put(const AKey: String; Value: Variant): IGridFSFile;
begin
  Result := inherited Put(AKey, Value) as IGridFSFile;
end;

function TGridFSFile.SetChunkSize(AChunkSize: Integer): IGridFSFile;
begin
  FChunkSize := AChunkSize;

  Result := Self;
end;

function TGridFSFile.SetContentType(AContentType: String): IGridFSFile;
begin
  FContentType := AContentType;

  Result := Self;
end;

procedure TGridFSFile.Store(AStream: TStream);
var
  vWriter: TGridFSFileWriter;
begin
  vWriter := TGridFSFileWriter.Create;
  try
    vWriter.Store(Self, AStream);
  finally
    vWriter.Free;
  end;
end;

{ TGridFsFileStreamReader }

function TGridFsFileStreamReader.Avaliable: Integer;
begin
  Result := 0;

  if Assigned(FCurrentChunkData) then
  begin
    Result := FCurrentChunkData.Stream.Size - FCurrentChunkData.Stream.Position;
  end;
end;

constructor TGridFsFileStreamReader.Create(AGridFsFile: TGridFSFile);
begin
  FGridFsFile := AGridFsFile;

  FNumChunks := FGridFsFile.numChunks;
  FCurrentChunk := -1;
end;

function TGridFsFileStreamReader.InternalRead(Count, FromPosition: Integer): Integer;
var
  vBytesToRead: Integer;
begin
  Self.Position := FromPosition;
  
  if (FCurrentChunkData = nil) or (Avaliable <= 0) then
  begin
    if (FCurrentChunk + 1) >= FNumChunks then
    begin
      Result := -1;
      Exit;
    end
    else
    begin
      Inc(FCurrentChunk);
      FCurrentChunkData := FGridFsFile.GetChunkData(FCurrentChunk);
    end;
  end;

  vBytesToRead := Min(Count, Avaliable);

  Result := Self.CopyFrom(FCurrentChunkData.Stream, vBytesToRead);

  if (Result < Count) then
  begin
    Result := Result + InternalRead(Count - Result, Position);
  end;
end;

function TGridFsFileStreamReader.Read(var Buffer; Count: Integer): Integer;
begin
  InternalRead(Count, 0);

  Self.Position := 0;

  Result := inherited Read(Buffer, Count);
end;

end.

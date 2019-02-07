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
unit BSONStream;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses Classes;

type
  TBSONStream = class(TMemoryStream)
  public
    function WriteUTF8String(value: String): Integer;
    procedure WriteInt(value: Integer);overload;
    procedure WriteInt(pos, value: Integer);overload;
    procedure WriteInt64(value: Int64);
    procedure WriteByte(value: Byte);
    procedure WriteDouble(value: Double);
    procedure WriteStream(ASource: TStream);

    function ReadInt: Integer;
    function ReadInt64: Int64;
    function ReadCString: String;
    function ReadUTF8String: String;
    function ReadObjectId: String;
    function ReadDouble: Double;
    function ReadByte: Byte;

  end;

implementation

uses SysUtils, BSON, MongoUtils;

{ TBSONStream }

procedure TBSONStream.WriteByte(value: Byte);
begin
  Write(value, SizeOf(Byte));
end;

procedure TBSONStream.WriteInt(value: Integer);
begin
  Write(value, SizeOf(Integer));
end;

procedure TBSONStream.WriteDouble(value: Double);
begin
  Write(value, SizeOf(Double));
end;

procedure TBSONStream.WriteInt(pos, value: Integer);
var
  vSavePos: Int64;
begin
  vSavePos := Position;
  Position := pos;
  WriteInt(value);
  Position := vSavePos; 
end;

procedure TBSONStream.WriteInt64(value: Int64);
begin
  Write(value, SizeOf(Int64));
end;

function TBSONStream.WriteUTF8String(value: String): Integer;
var
  vUTF8: UTF8String;
  vSize: Integer;
begin
  vUTF8 := TStringUtils.UTF8Encode(value);
  vSize := Length(vUTF8);
  Result := Write(PAnsiChar(vUTF8)^, vSize + 1);
end;

function TBSONStream.ReadInt: Integer;
begin
  Read(Result, SizeOf(Integer));
end;

function TBSONStream.ReadInt64: Int64;
begin
  Read(Result, 8);
end;

function TBSONStream.ReadCString: String;
var
  c: AnsiChar;
  s:AnsiString;
  vLength,vPos:integer;
begin
  vLength:=0;
  vPos:=0;
  Read(c, 1);
  while c <> #0 do
  begin
    if vPos = vLength then
    begin
      inc(vLength, 256);
      SetLength(s, vLength);
    end;

    inc(vPos);
    s[vPos]:=c;
    Read(c, 1);
  end;
  SetLength(s, vPos);

  Result := {$IFDEF Unicode}UTF8ToString(PAnsiChar(s));{$ELSE}UTF8Decode(s);{$ENDIF}
end;

function TBSONStream.ReadUTF8String: String;
var
  vLength: Integer;
  vTempResult:AnsiString;
begin
  vLength := ReadInt;

  vTempResult := '';

  if (vLength > 1) then
  begin
    SetLength(vTempResult, vLength-1);
    Read(vTempResult[1], vLength-1);
  end;

  ReadByte; //closing null

  {$IFDEF Unicode}
    Result := UTF8ToString(vTempResult);
  {$ELSE}
    {$IFDEF UNIX}
    Result := vTempResult;
    {$ELSE}
    Result := UTF8Decode(vTempResult);
    {$ENDIF}
  {$ENDIF}
end;

function TBSONStream.ReadObjectId: String;
const
  hex: array[0..15] of char='0123456789abcdef';
var
  oid: array[0..11] of byte;
begin
  Read(oid[0],12);

  Result := hex[oid[00] shr 4]+hex[oid[00] and $F]+
            hex[oid[01] shr 4]+hex[oid[01] and $F]+
            hex[oid[02] shr 4]+hex[oid[02] and $F]+
            hex[oid[03] shr 4]+hex[oid[03] and $F]+
            hex[oid[04] shr 4]+hex[oid[04] and $F]+
            hex[oid[05] shr 4]+hex[oid[05] and $F]+
            hex[oid[06] shr 4]+hex[oid[06] and $F]+
            hex[oid[07] shr 4]+hex[oid[07] and $F]+
            hex[oid[08] shr 4]+hex[oid[08] and $F]+
            hex[oid[09] shr 4]+hex[oid[09] and $F]+
            hex[oid[10] shr 4]+hex[oid[10] and $F]+
            hex[oid[11] shr 4]+hex[oid[11] and $F];
end;

function TBSONStream.ReadDouble: Double;
begin
  Read(Result, SizeOf(Double));
end;

function TBSONStream.ReadByte: Byte;
begin
  Read(Result, SizeOf(Byte));
end;

procedure TBSONStream.WriteStream(ASource: TStream);
var
  vPos: Int64;
begin
  vPos := ASource.Position;
  try
    ASource.Position := 0;
    CopyFrom(ASource, ASource.Size);
  finally
    ASource.Position := vPos;
  end;
end;

end.

{-------------------------------------------------------------------------------
MIT License

Copyright (c) 2018 - Present Zamrony P. Juhara

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
-------------------------------------------------------------------------------}
unit KeyValue;

{$MODE OBJFPC}
{$H+}

interface

uses

   classes,
   sysutils,
   contnrs;

type

   TKeyVal = record
      key: shortstring;
      value: string;
   end;
   PKeyVal = ^TKeyVal;

   { TKeyValue }

   TKeyValue = class
   private
       fHashList : TFPHashList;

       function has(const key: shortstring): boolean;
       function getVal(const key: shortstring): string;
       procedure setVal(const key: shortstring; const value: string);
       function getCount(): integer;
       function getKeyVal(const idx: integer): TKeyVal;
       procedure cleanup();
   public
       constructor Create();
       destructor Destroy(); override;
       function Clone(): TKeyValue;

       procedure remove(const key: shortstring);

       property value[const key:shortstring] : string read getVal write setVal; default;
       property exist[const key:shortstring] : boolean read has;

       // these properties are provided so that caller may read all key values
       property items[const idx: integer] : TKeyVal read getKeyVal;
       property count : integer read getCount;
   end;

implementation

constructor TKeyValue.Create();
begin
   fHashList := TFPHashList.create();
end;

destructor TKeyValue.Destroy();
begin
   cleanUp();
   fHashList.Free;
end;

function TKeyValue.Clone(): TKeyValue;
var i: integer;
    kv: TKeyVal;
begin
    result := TKeyValue.Create();
    for i:= 0 to count - 1 do
    begin
        kv := items[i];
        result[kv.key] := kv.value;
    end;
end;

function TKeyValue.has(const key: shortstring): boolean;
begin
    result := (fHashList.Find(key) <> nil);
end;


function TKeyValue.getVal(const key: shortstring): string;
var kv: PKeyVal;
begin
    kv := fHashList.Find(key);
    if kv = nil then
    begin
        // for generic key value store maybe we want to throw exception instead
        // of empty string but for know we only want to use this to store HTTP
        // headers key value so empty string should suffice if http header not found
        result := '';
        exit;
    end;
    result := kv^.value;
end;

procedure TKeyValue.setVal(const key: shortstring; const value: string);
var kv: PKeyVal;
begin
    kv := fHashList.Find(key);
    if kv = nil then
    begin
        new(kv);
        kv^.key := key;
        kv^.value := value;
        fHashList.Add(key, kv);
    end else
    begin
        kv^.value := value;
    end;
end;

function TKeyValue.getCount(): integer;
begin
    result := fHashList.Count;
end;

function TKeyValue.getKeyVal(const idx: integer): TKeyVal;
var i: integer;
    kv: PKeyVal;
begin
    result := default(TKeyVal);
    if i < fHashList.count then
    begin
       kv := fHashList.Items[i];
       result := kv^;
    end;
end;

procedure TKeyValue.remove(const key: shortstring);
var kv: PKeyVal;
begin
    kv := fHashList.Find(key);
    if kv <> nil then
    begin
        fHashList.Delete(fHashList.FindIndexOf(key));
        dispose(kv);
    end;
end;

procedure TKeyValue.cleanup();
var i:integer;
    kv: PKeyVal;
begin
    for i:= fHashList.Count-1 downto 0 do
    begin
        kv := fHashList.Items[i];
        dispose(kv);
        fHashList.Delete(i);
    end;
end;

end.

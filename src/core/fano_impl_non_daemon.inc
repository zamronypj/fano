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

uses
   {$IFDEF WINDOWS}
   Windows,
   {$ELSE}
   BaseUnix,
   Unix,
   {$ENDIF}
   HttpHeaders,
   HttpParser;

var
    mainCfg: TFanoConfig;

function fanoConfig(): TFanoConfig; overload;
begin
   result := mainCfg;
end;

function fanoConfig(const newCfg: TFanoConfig): TFanoConfig; overload;
begin
   mainCfg := newCfg;
   result := mainCfg;
end;


function fanoCreate(): TFanoConfig;
begin
   result := fanoConfig();
end;

// this is run as CGI (RFC 3875) app so we need
// read CGI environment vars given by web server
// https://www.rfc-editor.org/rfc/rfc3875
function fanoRun(): longint;
const BUFF_SIZE = 4*1024;
var InStream: TStream;
    Buffer: string;
    BytesRead: Integer;
    httpData: THttpData;
    oldState: THttpProcessingState;
    StdInHandle: THandle;
begin
   // TODO:
   // CGI https://www.rfc-editor.org/rfc/rfc3875
   // - read CGI environment variable
   // - CONTENT_TYPE contains request Content-Type header such application/json etc
   // - REQUEST_METHOD contains request method GET, POST etc
   // - PATH_INFO contains request path
   // - QUERY_STRING contains request query string
   // - if CONTENT_LENGTH env variable set (Content-Length header), meaning
   //   we have request body in STDIN (POST/PUT body)
   // --- read STDIN as much as CONTENT_LENGTH
   httpData := default(THttpData);
   httpData.headers := THttpHeaders.create();

   httpData.httpMethod := httpMethodFromStr(GetEnvironmentVariable('REQUEST_METHOD'));
   httpData.headers['Content-Type'] := GetEnvironmentVariable('CONTENT_TYPE');
   httpData.headers['Content-Length'] := GetEnvironmentVariable('CONTENT_LENGTH');

   InStream := TFileStream.Create('stdin.txt', fmOpenRead, fmShareDenyNone);
   {$IFDEF WINDOWS}
   //stdInHandle := GetStdHandle(STD_INPUT_HANDLE);
   {$ELSE}
   stdInHandle := StdInputHandle;
   {$ENDIF}

   //InStream := THandleStream.Create(StdInHandle);
   try
       SetLength(Buffer, BUFF_SIZE);
       httpData.pos := 0;
       while true do
       begin
           httpData.pos := InStream.Position;
           BytesRead := InStream.Read(Buffer[1], BUFF_SIZE);
           if BytesRead < 1 then
           begin
              break;
           end;
           oldState := httpData.state;
           HttpParser.parseHttp(inStream, httpData);
           if oldState = httpData.State then
           begin
               // we havent found what we are looking so keep reading at prev pos
               inStream.position := httpData.pos;
           end;
       end;
       result := 0;
   finally
       InStream.Free();
       httpData.headers.Free();
   end;
end;

function fanoFree(): longint;
begin
   mainCfg := default(TFanoConfig);
   result := 0;
end;

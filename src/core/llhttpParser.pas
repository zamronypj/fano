unit llhttpParser;

interface

{$MODE OBJFPC}
{$H+}

uses

   classes,
   ctypes,
   {$IFDEF UNIX}
   unixtype,
   {$ENDIF}
   sysutils,
   uhttp,
   HttpHeaders,
   llhttp;

type

    THttpProcessingState = (
       hpsWaitingHeader,
       hpsReadingHeader,
       hpsReadingBody,
       hpsComplete,

       // when request has invalid data
       hpsBadRequest,

       // when request contain body but not header Content-Length
       hpsLengthRequired,

       // when request too big such as POST body size etc
       hpsRequestTooLarge
    );


    THttpData = record
       state: THttpProcessingState;
       parser: llhttp_t;
       httpMethod : THttpMethod;
       requestPath: string;
       httpVersion : string;
       headers: THttpHeaders;
       expectBody: boolean;
       expectedBodySize: integer;
       body: TStream;
       isMultipart: boolean;
       files: TUploadedFiles;
       isChunked: boolean;

       // this will store last offset of processed buffer
       pos: integer;

       maxBodySize: integer;
    end;
    PHttpData = ^THttpData;

procedure initParser(var httpData: THttpData);
procedure parseHttp(inStream: TStream; var httpData: THttpData);

implementation

const MAX_LEN = 2048;

var settings: llhttp_settings_t;

function on_message_begin(parser: pllhttp_t): integer; cdecl;
begin
    writeln('parse start');
    result := 0;
end;

function on_url(parser: pllhttp_t; const at: PAnsiChar; length: size_t): integer; cdecl;
var url: ansistring;
begin
    url := copy(at, 1, length);
    writeln('on_url: ', url);
    result:= 0;
end;


function on_header_field(parser: pllhttp_t; const at : PAnsiChar; length: size_t): integer; cdecl;
var header_field: ansistring;
begin
    header_field := copy(at, 1, length);
    writeln('head field: ', header_field);
    result := 0;
end;

function on_header_value(parser: pllhttp_t; const at : PAnsiChar; length: size_t): integer; cdecl;
var header_value: ansistring;
begin
    header_value := copy(at, 1, length);
    writeln('head value: ', header_value);
    result := 0;
end;

function on_headers_complete(parser: pllhttp_t): integer; cdecl;
begin
    writeln('on_headers_complete, major: ', parser^.http_major,
      ' minor: ', parser^.http_minor,
      'keep-alive: ', llhttp_should_keep_alive(parser),
      'upgrade: ', parser^.upgrade);
    result := 0;
end;

function on_body(parser: pllhttp_t; const at: PAnsichar; length: size_t): integer; cdecl;
var body: string;
begin
    body := copy(at, 1, length);
    writeln('on body: ', body);
    result := 0;
end;

function on_message_complete(parser: pllhttp_t): integer; cdecl;
begin
    writeln('on_message_complete');
    result := 0;
end;

function on_reset(parser: pllhttp_t): integer; cdecl;
begin
    writeln('on_reset');
    result := 0;
end;

procedure initSettings();
begin
    llhttp_settings_init(@settings);

    settings.on_message_begin := @on_message_begin;
    settings.on_url := @on_url;
    settings.on_header_field := @on_header_field;
    settings.on_header_value := @on_header_value;
    settings.on_headers_complete := @on_headers_complete;
    settings.on_body := @on_body;
    settings.on_reset := @on_reset;
    settings.on_message_complete := @on_message_complete;
end;

procedure initParser(var httpData: THttpData);
begin
    // we act as server so, only concern parsing HTTP_REQUEST
    llhttp_init(@httpData.parser, HTTP_REQUEST, @settings);
end;

procedure parseHttp(inStream: TStream; var httpData: THttpData);
var err: llhttp_errno;
    memInStream: TMemoryStream;
    nRead: integer;
    data : PChar;
begin
    memInStream := TMemoryStream(inStream);
    nRead := memInStream.size - httpData.pos;
    data := PChar(PByte(memInStream.Memory + httpData.pos));
    err := llhttp_execute(@httpData.parser, data, nRead);
    if err <> HPE_OK then
    begin
       nRead := llhttp_get_error_pos(@httpData.parser) - data;
       writeln(stderr, 'Parse error: ', llhttp_errno_name(err),' ', httpData.parser.reason);
       // todo handle error
       if (err <> HPE_PAUSED) or (err <> HPE_PAUSED_UPGRADE) or (err <> HPE_PAUSED_H2_UPGRADE) then
       begin
           httpData.state:= hpsBadRequest;
       end;
    end;
    httpData.pos := nRead;
end;

initialization
   initSettings();
end.

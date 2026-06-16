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

       // number of octets header read from parser, if it exceeds
       // maxHeaderSize we will stop parsing and return HTTP error 413
       // Content Too Large
       headerLenRead: integer;

       // number of octets header we allowed to process
       maxHeaderSize: integer;

       // number of octets body read from parser, if it exceeds
       // maxBodySize we will stop parsing and return HTTP error 413
       // Content Too Large
       bodyLenRead: integer;

       // number of octets body we allowed to process
       maxBodySize: integer;

       currentHeader: shortstring;
    end;
    PHttpData = ^THttpData;

procedure initParser(var httpData: THttpData);
procedure parseHttp(inStream: TStream; var httpData: THttpData);
procedure finishParser(var httpData: THttpData);

implementation

const MAX_LEN = 2048;

var settings: llhttp_settings_t;

function on_message_begin(parser: pllhttp_t): integer; cdecl;
var ahttpData: PHttpData;
begin
    ahttpData := PHttpData(parser^.data);
    ahttpData^.headerLenRead := 0;
    ahttpData^.state := hpsWaitingHeader;
    {$IFDEF VERBOSE}
    writeln('parse start');
    {$ENDIF}
    result := integer(HPE_OK);
end;

function trackHeaderSize(parser: pllhttp_t; length: size_t; var ahttpData: PHttpData): llhttp_errno_t; inline;
begin
    inc(ahttpData^.headerLenRead, length);
    if (ahttpData^.headerLenRead > ahttpData^.maxHeaderSize) then
    begin
       ahttpData^.state := hpsRequestTooLarge;
       llhttp_set_error_reason(parser, 'exceed_max_header_size');
       result := HPE_USER;
    end;
    result := HPE_OK;
end;

function trackBodySize(parser: pllhttp_t; length: size_t; var ahttpData: PHttpData): llhttp_errno_t; inline;
begin
    inc(ahttpData^.bodyLenRead, length);
    if (ahttpData^.bodyLenRead > ahttpData^.maxBodySize) then
    begin
       ahttpData^.state := hpsRequestTooLarge;
       llhttp_set_error_reason(parser, 'exceed_max_body_size');
       result := HPE_USER;
    end;
    result := HPE_OK;
end;

function on_url(parser: pllhttp_t; const at: PAnsiChar; length: size_t): integer; cdecl;
var ahttpData: PHttpData;
    res: llhttp_errno_t;
begin
    ahttpData := PHttpData(parser^.data);

    res := trackHeaderSize(parser, length, ahttpData);
    if res <> HPE_OK then
    begin
       exit(integer(res));
    end;

    ahttpData^.requestPath:= copy(at, 1, length);

    {$IFDEF VERBOSE}
    writeln('on_url: ', ahttpData^.requestPath);
    {$ENDIF}

    result:= integer(HPE_OK);
end;


function on_header_field(parser: pllhttp_t; const at : PAnsiChar; length: size_t): integer; cdecl;
var ahttpData: PHttpData;
    res: llhttp_errno_t;
begin
    ahttpData := PHttpData(parser^.data);

    res := trackHeaderSize(parser, length, ahttpData);
    if res <> HPE_OK then
    begin
       exit(integer(res));
    end;

    ahttpData^.currentHeader := copy(at, 1, length);
    ahttpData^.headers[ahttpData^.currentHeader] := '';
    ahttpData^.state := hpsReadingHeader;

    {$IFDEF VERBOSE}
    writeln('head field: ', ahttpData^.currentHeader);
    {$ENDIF}

    result := integer(HPE_OK);
end;

function on_header_value(parser: pllhttp_t; const at : PAnsiChar; length: size_t): integer; cdecl;
var ahttpData: PHttpData;
    header_value: ansistring;
    res: llhttp_errno_t;
begin
    ahttpData := PHttpData(parser^.data);
    res := trackHeaderSize(parser, length, ahttpData);
    if res <> HPE_OK then
    begin
       exit(integer(res));
    end;

    header_value := copy(at, 1, length);
    ahttpData^.headers[ahttpData^.currentHeader] := header_value;

    {$IFDEF VERBOSE}
    writeln('head value: ', header_value);
    {$ENDIF}

    result := integer(HPE_OK);
end;

function on_headers_complete(parser: pllhttp_t): integer; cdecl;
begin
    {$IFDEF VERBOSE}
    writeln('on_headers_complete, major: ', parser^.http_major,
      ' minor: ', parser^.http_minor,
      'keep-alive: ', llhttp_should_keep_alive(parser),
      'upgrade: ', parser^.upgrade);
    {$ENDIF}

    if (parser^.method = byte(HTTP_GET)) or
       (parser^.method = byte(HTTP_HEAD)) then
    begin
       // this tell parser that no body expected , so dont bother to parse body
       // and can continue to next request
       exit(1);
    end;

    result := 0;
end;

function on_body(parser: pllhttp_t; const at: PAnsichar; length: size_t): integer; cdecl;
var ahttpData: PHttpData;
    res: llhttp_errno_t;
begin
    ahttpData := PHttpData(parser^.data);

    res := trackBodySize(parser, length, ahttpData);
    if res <> HPE_OK then
    begin
       // if length exceed max body size we will return HPE_USER and stop
       exit(integer(res));
    end;

    ahttpData^.state := hpsReadingBody;
    if ahttpData^.body = nil then
    begin
       ahttpData^.body := TMemoryStream.create();
    end;
    ahttpData^.body.Read(at^, length);
    result := integer(HPE_OK);
end;

function on_message_complete(parser: pllhttp_t): integer; cdecl;
var ahttpData: PHttpData;
begin
    ahttpData := PHttpData(parser^.data);
    ahttpData^.state := hpsComplete;
    {$IFDEF VERBOSE}
    writeln('on_message_complete');
    {$ENDIF}
    result := integer(HPE_OK);
end;

function on_reset(parser: pllhttp_t): integer; cdecl;
begin
    {$IFDEF VERBOSE}
    writeln('on_reset');
    {$ENDIF}
    result := integer(HPE_OK);
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
    nRead, remainingBytes: integer;
    pausedPos: NativeUint;
    data : PChar;
begin
    memInStream := TMemoryStream(inStream);
    nRead := memInStream.size - httpData.pos;
    while nRead > 0 do
    begin
        data := PChar(PByte(memInStream.Memory + httpData.pos));
        err := llhttp_execute(@httpData.parser, data, nRead);
        if err = HPE_OK then
        begin
           httpData.pos := nRead;
           nRead := 0;
        end else
        if err = HPE_PAUSED then
        begin
         pausedPos := PtrUInt(llhttp_get_error_pos(@httpData.parser));
           nRead := nRead - (pausedPos - httpData.pos);
           httpData.pos := pausedPos;
           llhttp_resume(@httpData.parser);
        end else
        if err = HPE_PAUSED_UPGRADE then
        begin
           // TODO handle paused upgrade request such as upgrade to websocket etc
           pausedPos := PtrUInt(llhttp_get_error_pos(@httpData.parser));
           nRead := nRead - (pausedPos - httpData.pos);
           httpData.pos := pausedPos;
           llhttp_resume(@httpData.parser);
        end else
        if err = HPE_PAUSED_H2_UPGRADE then
        begin
           // TODO handle paused upgrade request such as upgrade to HTTP/2
           pausedPos := PtrUInt(llhttp_get_error_pos(@httpData.parser));
           nRead := nRead - (pausedPos - httpData.pos);
           httpData.pos := pausedPos;
           llhttp_resume(@httpData.parser);
        end else
        if err = HPE_USER then
        begin
           nRead := llhttp_get_error_pos(@httpData.parser) - data;
           writeln(stderr, 'Parse error: ', llhttp_errno_name(err),' ', httpData.parser.reason);
           // no need to set httpData.state as it is already set
           // see trackBodySize(), trackHeaderSize();
        end else
        begin
           nRead := llhttp_get_error_pos(@httpData.parser) - data;
           writeln(stderr, 'Parse error: ', llhttp_errno_name(err),' ', httpData.parser.reason);
           httpData.state := hpsBadRequest;
        end;
    end;
end;

procedure finishParser(var httpData: THttpData);
begin
    llhttp_finish(@httpData.parser);
end;

initialization
   initSettings();
end.

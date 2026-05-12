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
unit HttpParser;

{$MODE OBJFPC}
{$H+}

interface

uses


   classes,
   sysutils,
   HttpHeaders;

type
    THttpMethod = (
        hmUnknown,
        hmGET,
        hmPOST,
        hmPUT,
        hmPATCH,
        hmDELETE,
        hmHEAD,
        hmOPTIONS,
        hmCONNECT,
        hmTRACE
    );
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

    TUploadedFile = record
       // actual file path where binary stream stored in server
       filename: string;
       // original file name as sent by client
       originalFilename: string;
       // content type of file
       contentType: string;
    end;
    TUploadedFiles = array of TUploadedFile;

    THttpData = record
       state: THttpProcessingState;
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
       pos: integer;
       maxBodySize: integer;
    end;

function httpMethodFromStr(const method: string): THttpMethod;
procedure parseHttp(inStream: TStream; var httpData: THttpData);

implementation

function httpMethodFromStr(const method: string): THttpMethod;
begin
    result := hmUnknown;
    case method of
        'GET' : result := hmGET;
        'POST' : result := hmPOST;
        'PUT' : result := hmPUT;
        'PATCH' : result := hmPATCH;
        'DELETE' : result := hmDELETE;
        'HEAD' : result := hmHEAD;
        'OPTIONS' : result := hmOPTIONS;
        'CONNECT' : result := hmCONNECT;
        'TRACE' : result := hmTRACE;
    end;
end;

function isDigit(c: char): boolean;
begin
    result := (ord(c) >= ord('0')) and (ord(c) <= ord('9'));
end;

function isAlpha(c: char): boolean;
begin
    result := ((ord(c) >= ord('a')) and (ord(c) <= ord('z'))) or
       ((ord(c) >= ord('A')) and (ord(c) <= ord('Z')));
end;

function isHexDigit(c: char): boolean;
begin
   result := ((ord(c) >= ord('0')) and (ord(c) <= ord('9'))) or
      ((ord(c) >= ord('a')) and (ord(c) <= ord('f'))) or
      ((ord(c) >= ord('A')) and (ord(c) <= ord('F')));
end;

// From RFC 3986:
//   sub-delims = "!" / "$" / "&" / "'" / "(" / ")"
//              / "*" / "+" / "," / ";" / "="
function isSubDelim(c: char): boolean;
begin
    result := (c = '!') or (c = '$') or (c = '&') or (c = '''') or
        (c = '(') or (c = ')') or (c = '*') or (c = '+') or
	(c = ',') or (c = ';') or (c = '=');
end;


// token char
function isTokenChar(c: char) : boolean;
begin
    result := isDigit(c) or isAlpha(c) or
        (c = '!') or (c = '#') or (c = '$') or (c = '%') or
        (c = '&') or (c = '''') or (c = '*') or (c = '+') or
        (c = '-') or (c = '.') or (c = '^') or (c = '_') or
        (c = '`') or (c = '|') or (c = '~');
end;

function isVersionChar(c:char):boolean;
begin
    result := (c = 'H') or (c='T') or (c='P') or (c='/') or (c='.') or isDigit(c);
end;

function isVisibleChar(c: char): boolean;
begin
    result := (ord(c) >= ord(' ')) and  (ord(c) <= ord('~'));
end;

function isWhitespace(c: char): boolean;
begin
    result := (c = ' ') or  (c = #9); // space or tab
end;

function consumeStr(var inStream: TStream; const token: string): boolean;
var  i, tokenLen: integer;
     tmpPos: int64;
begin
    tokenLen := length(token);
    if tokenLen = 0 then
    begin
        exit(false);
    end;

    if tokenLen > (inStream.size - inStream.position) then
    begin
        exit(false);
    end;

    tmpPos := inStream.Position;
    for i := 1 to tokenLen do
    begin
        if inStream.readByte <> ord(token[i]) then
        begin
            inStream.position := tmpPos;
            exit(false);
        end;
    end;

    result:= true;
end;

// look for double CRLF that mark end of header in data stream read from client
// if found then header is complete
function hasCompleteHeader(inStream: TStream): boolean;
var eofHeader : shortstring;
    apos, savedPos: integer;
begin
    if inStream.size < 4 then
    begin
        exit(false);
    end;
    setLength(eofHeader, 4);
    savedPos := inStream.Position;
    // always start from beginning of stream to avoid misread
    inStream.Position := 0;
    apos := 0;
    while apos < inStream.size do
    begin
        inStream.Read(eofHeader[1], 4);
        if (eofHeader = #13#10#13#10) then
        begin
          exit(true);
        end;
        // we read 4 bytes, need to advance 1 byte at a time to avoid miss
        inc(apos);
        instream.position := apos;
    end;
    result := false;
    instream.position := savedPos;
end;

function parseRequestTarget(var inStream: TStream; var url: string): boolean;
const
    OK = true;
    BAD_REQUEST = false;
var
    savedPos, aUrlLen: integer;
begin
    savedPos := inStream.position;
    aUrlLen := 0;

    while inStream.ReadByte <> ord(' ') do
    begin
        inc(aUrlLen);
    end;

    if inStream.position >= inStream.size then
    begin
        exit(BAD_REQUEST);
    end;

    setLength(url, aUrlLen);
    inStream.Position:= savedPos;
    // TODO: need to check if it is valid url to avoid bad or malicious data
    inStream.read(url[1], aUrlLen);

    result := OK;
end;

function parseVersion(var inStream: TStream; var version: string) : boolean;
const
    OK = true;
    BAD_REQUEST = false;
var
    savedPos, aVerLen: integer;
begin
    savedPos := inStream.position;
    aVerLen := 0;

    while isVersionChar(chr(inStream.ReadByte)) do
    begin
        inc(aVerLen);
    end;

    if inStream.position >= inStream.size then
    begin
        exit(BAD_REQUEST);
    end;

    setLength(version, aVerLen);
    inStream.Position:= savedPos;
    // TODO: need to check if it is valid version to avoid bad or malicious data
    inStream.read(version[1], aVerLen);

    result := OK;
end;

function parseHeader(var inStream: TStream; var headers: THttpHeaders) : integer;
const
    COMPLETE = 0;
    OK = 1;
    BAD_REQUEST = -1;
var
    savedPos, aLen: integer;
    headerName: shortstring;
    headerValue: string;
    eofline: array[0..1] of char;
begin
    savedPos := inStream.position;
    aLen := 0;

    if (savedPos = inStream.Size) then
    begin
        exit(BAD_REQUEST);
    end;

    if not isTokenChar(chr(inStream.readByte)) then
    begin
        exit(BAD_REQUEST);
    end;
    inc(aLen);

    while (inStream.position < inStream.Size) and (isTokenChar(chr(inStream.ReadByte))) do
    begin
        inc(aLen);
    end;

    if inStream.position >= inStream.size then
    begin
        exit(BAD_REQUEST);
    end;

    // read header name
    setLength(headerName, aLen);
    inStream.Position:= savedPos;
    // TODO: need to check if it is valid header name to avoid bad or malicious data
    inStream.read(headerName[1], aLen);

    headers[headerName] := '';

    if inStream.position >= inStream.size then
    begin
        exit(BAD_REQUEST);
    end;

    // RFC 9112: no whitespace allowed between header name and :
    if chr(inStream.readByte) <> ':' then
    begin
        exit(BAD_REQUEST);
    end;

    while (inStream.position < inStream.Size) and (isWhitespace(chr(inStream.ReadByte))) do
    begin
        // consume whitespace preceeding value
    end;

    // -1 because we already read first non whitespace
    inStream.position := inStream.position - 1;
    savedPos := inStream.position;
    aLen := 0;

    while (inStream.position < inStream.Size) and (isVisibleChar(chr(inStream.ReadByte))) do
    begin
        inc(alen);
    end;

    // read header value
    setLength(headerValue, aLen);
    inStream.Position:= savedPos;
    // TODO: need to check if it is valid header name to avoid bad or malicious data
    inStream.read(headerValue[1], aLen);

    headers[headerName] := headerValue;

    while (inStream.position < inStream.Size) and (isWhitespace(chr(inStream.ReadByte))) do
    begin
        // consume any trailing whitespace after value and
    end;

    // -1 because we already read first non whitespace
    inStream.position := inStream.position - 1;

    if (inStream.Size - inStream.position < 2) then
    begin
        // no CRLF
        exit(BAD_REQUEST);
    end;

    // consume CRLF
    inStream.read(eofline[0], 2);
    if (eofline[0] <> #13) or (eofline[1] <> #10) then
    begin
        // no CRLF
        exit(BAD_REQUEST);
    end;

    if inStream.Size - inStream.position > 2 then
    begin
        result := OK;
    end else
    begin
        // this is end of header as last CRLF mark end of header
        result := COMPLETE;
    end;
end;

function parseHeaders(var inStream: TStream; var headers: THttpHeaders) : boolean;
const
    COMPLETE = 0;
    BAD_REQUEST = -1;
var ret: integer;
begin
    repeat
       ret := parseHeader(inStream, headers);
    until (ret = COMPLETE) or (ret = BAD_REQUEST);
    result := (ret = COMPLETE)
end;

// handle body data sent with
// Transfer-Encoding: chunked
function parseChunkedBody(inStream: TStream; var httpData: THttpData): THttpProcessingState;
begin

end;

function GetRandomFileName(const Extension: string): string;
var
  Guid: TGUID;
begin
  if CreateGUID(Guid) = 0 then
    // Convert GUID to string and remove the curly braces {}
    Result := GUIDToString(Guid).Substring(1, 36) + Extension
  else
    Result := ''; // Error handling
end;

// handle body data sent with
// Content-Length: [num bytes]
function  parseFixedLengthBody(inStream: TStream; var httpData: THttpData): THttpProcessingState;
var buf: array[0..1024-1] of byte;
    totRead: int64;
begin
    result := hpsReadingBody;
    if httpData.expectedBodySize > 0 then
    begin
        if httpData.body = nil then
        begin
            if httpData.isMultipart then
            begin
                httpData.body := TFileStream.create(GetRandomFileName('.tmp'), fmCreate);
            end else
            begin
                httpData.body := TMemoryStream.create();
                // TODO: do we need to preallocate to avoid frequent memory
                // reallocation for example half of max body? need to profile first
                // TMemoryStream(httpData.body).Capacity := httpData.maxBodySize div 2;
            end;
        end;

        repeat
            totRead := inStream.Read(buf[0], 1024);
            if totRead > 0 then
            begin
                httpData.body.Write(buf[0], totRead);
            end;

            // TODO: parse any POST/PUT/PATCH data and also parse uploaded file
        until (httpData.body.size = httpData.expectedBodySize) or
            // if totRead less than 1024, inStream has no more data to read
            // at the moment so we should retry later
           (totRead < 1024);

        if httpData.body.size = httpData.expectedBodySize then
        begin
            result := hpsComplete;
        end;
    end else
    begin
        result := hpsComplete;
    end;
end;

function parseBody(inStream: TStream; var httpData: THttpData): THttpProcessingState;
begin
    if httpData.isChunked then
    begin
        result := parseChunkedBody(inStream, httpData);
    end else
    begin
        result := parseFixedLengthBody(inStream, httpData);
    end;
end;

procedure parseHttp(inStream: TStream; var httpData: THttpData);
var savedPos: integer;
begin
    if httpData.state = hpsWaitingHeader then
    begin
        if hasCompleteHeader(inStream) then
        begin
            httpData.state := hpsReadingHeader;
            savedPos := inStream.position;
            inStream.position := 0;
        end else
        begin
            // TODO: not very efficient as it just wait and
            // retry later until we have more data. Should just parse any incomplete
            // headers as much as possible in one read
            exit;
        end;
    end;

    if consumeStr(inStream, 'GET') then
    begin
        httpData.httpMethod := hmGET;
    end else
    if consumeStr(inStream, 'POST') then
    begin
        httpData.httpMethod := hmPOST;
    end else
    if consumeStr(inStream, 'PUT') then
    begin
        httpData.httpMethod := hmPUT;
    end else
    if consumeStr(inStream, 'DELETE') then
    begin
        httpData.httpMethod := hmDELETE;
    end else
    if consumeStr(inStream, 'PATCH') then
    begin
        httpData.httpMethod := hmPATCH;
    end else
    if consumeStr(inStream, 'HEAD') then
    begin
        httpData.httpMethod := hmHEAD;
    end else
    if consumeStr(inStream, 'OPTIONS') then
    begin
        httpData.httpMethod := hmOPTIONS;
    end else
    if consumeStr(inStream, 'CONNECT') then
    begin
        httpData.httpMethod := hmCONNECT;
    end else
    if consumeStr(inStream, 'TRACE') then
    begin
        httpData.httpMethod := hmTRACE;
    end else
    begin
        httpData.state:= hpsBadRequest;
        exit;
    end;

    // method and request url must be separated by 1 space
    if inStream.ReadByte <> ord(' ') then
    begin
        httpData.state:= hpsBadRequest;
        exit;
    end;

    if not parseRequestTarget(inStream, httpData.requestPath) then
    begin
        httpData.state:= hpsBadRequest;
        exit;
    end;

    // request url and version must be separated by 1 space
    if inStream.ReadByte <> ord(' ') then
    begin
        httpData.state:= hpsBadRequest;
        exit;
    end;

    if not parseVersion(inStream, httpData.httpVersion) then
    begin
        httpData.state:= hpsBadRequest;
        exit;
    end;

    // version and header must be separated by 1 CRLF
    if not consumeStr(inStream, #13#10) then
    begin
        httpData.state:= hpsBadRequest;
        exit;
    end;

    if parseHeaders(inStream, httpData.headers) then
    begin
        // reading header complete, next do reading body
        httpData.state:= hpsReadingBody;
    end else
    begin
        httpData.state:= hpsBadRequest;
        exit;
    end;

    httpData.expectBody:= (httpData.httpMethod = hmPOST) or
       (httpData.httpMethod = hmPUT) or
       (httpData.httpMethod = hmPATCH);

    httpData.expectedBodySize := 0;
    httpData.isChunked := false;
    if httpData.expectBody then
    begin
        if httpData.headers.exist['Content-Length'] then
        begin
            if not tryStrToInt(httpData.headers['Content-Length'], httpData.expectedBodySize) then
            begin
                httpData.state:= hpsBadRequest;
                exit;
            end;
        end;

        if httpData.headers.exist['Transfer-Encoding'] then
        begin
            // reset any expectedBodySize value read from Content-Length header as
            // only one allowed not both,
            // according to RFC 9112 Transfer-Encoding must take precedence
            httpData.expectedBodySize := 0;
            httpData.isChunked := true;
        end;

        if not httpData.isChunked then
        begin
            if httpData.expectedBodySize = 0 then
            begin
               httpData.state:= hpsLengthRequired;
               exit;
            end;

            if (httpData.expectedBodySize > httpData.maxBodySize) then
            begin
               httpData.state:= hpsRequestTooLarge;
               exit;
            end;
        end;

        httpData.state := parseBody(inStream, httpData);
    end;

end;

//procedure parseHttpVerb(tmp: string; len:integer; var httpData: THttpData; var idx: integer; var needMoreData: boolean);
//const MAX_VERB = 9;
//var verbs : array[0..MAX_VERB - 1] of string;
//    idxVerb, verbLen, idxV, tmpIdxV, idxchar, idxComp: integer;
//    verbMatched: boolean;
//begin
//    verbs[0] := 'GET';
//    verbs[1] := 'POST';
//    verbs[2] := 'DELETE';
//    verbs[3] := 'PATCH';
//    verbs[4] := 'PUT';
//    verbs[5] := 'HEAD';
//    verbs[6] := 'OPTIONS';
//    verbs[7] := 'CONNECT';
//    verbs[8] := 'TRACE';
//    idxVerb := 0;
//    idxV := idx;
//    needMoreData := false;
//    repeat
//        if idxV > len then
//        begin
//            exit;
//        end;
//
//        if tmp[idxV] = ' ' then
//        begin
//            inc(idxV);
//            inc(idx);
//        end else
//        begin
//            repeat
//                tmpIdxV := idxV;
//                idxComp := 1;
//                verbLen := length(verbs[idxVerb]);
//
//                // assumed matched if incoming data from client is longer than
//                // verb length otherwise not matched
//                verbMatched := (len >= verbLen);
//
//                if not verbMatched then
//                begin
//                    // definitely not matched, no need to check further.
//                    // continue to next verb
//                    inc(idxVerb);
//                    continue;
//                end;
//
//                repeat
//                    if uppercase(tmp[idxV]) <> verbs[idxVerb][idxComp] then
//                    begin
//                        verbMatched := false;
//                        break;
//                    end else
//                    begin
//                        inc(idxV);
//                        inc(idxComp);
//                    end;
//                until ((idxV > len) or (idxComp > verbLen)) and (len >= verbLen);
//
//                if verbMatched then
//                begin
//                    httpData.httpVerb := verbs[idxVerb];
//                    httpData.state := hpsReadingPath;
//                    idx := idxV;
//                    exit;
//                end;
//
//                if (idxV > len) then
//                begin
//                    break;
//                end;
//                idxV := tmpIdxV;
//                inc(idxVerb);
//            until (idxVerb >= MAX_VERB);
//        end;
//    until (idxV > len) or (idxVerb >= MAX_VERB);
//
//    // if state not changed then verb data is not yet fully retrieved
//    // from network, just advance and retry later when we have more data coming
//    needMoreData := (httpData.state = hpsReadingVerb)
//end;
//
//procedure parseHttpRequestPath(tmp: string; len:integer; var httpData: THttpData; var idx: integer; var needMoreData: boolean);
//var idxPath: integer;
//begin
//    needMoreData := false;
//    idxPath := idx;
//    repeat
//        // skip space
//        if tmp[idxPath] = ' ' then
//        begin
//            inc(idx);
//            inc(idxPath);
//            continue;
//        end;
//
//        if tmp[idxPath] <> ' ' then
//        begin
//            inc(idxPath);
//        end else
//        if (tmp[idxPath]  = #13) and (httpData.requestPath = '') then
//        begin
//            //
//        end else
//        begin
//            httpData.requestPath:= copy(tmp, idx, idxPath - idx);
//            httpData.state := hpsReadingVersion;
//            idx := idxPath;
//        end;
//    until (httpData.state <> hpsReadingPath) or (idxPath >= len);
//
//    // if state not changed then request path data is not yet fully retrieved
//    // from network, just advance and retry later when we have more data coming
//    needMoreData := (httpData.state = hpsReadingPath)
//end;
//
//procedure parseHttpVersion(tmp: string; len:integer; httpData: THttpData; var idx: integer; var needMoreData: boolean);
//var idxVer: integer;
//begin
//    idxVer := idx;
//    repeat
//        if tmp[idxVer] = ' ' then
//        begin
//            // skip space
//            inc(idx);
//            inc(idxVer);
//            continue;
//        end;
//
//        if tmp[idxVer] <> #13 then
//        begin
//            inc(idxVer);
//        end else
//        begin
//            httpData.httpVersion:= copy(tmp, idx, idxVer - idx);
//            httpData.state := hpsReadingHeader;
//            idx := idxVer + 1; //+1 because at the end there is CRLF
//        end;
//    until (httpData.state <> hpsReadingVersion) or (idxVer >= len);
//
//    // if state not changed then version data is not yet fully retrieved
//    // from network, just advance and retry later when we have more incoming data
//    needMoreData := (httpData.state = hpsReadingVersion)
//end;
//
//procedure parseHttpHeader(tmp: string; len:integer; var httpData: THttpData; var idx: integer; var needMoreData: boolean);
//var idxHdr: integer;
//begin
//    needMoreData := false;
//    idxHdr := idx;
//    repeat
//
//    until (httpData.state <> hpsReadingHeader) or (idxHdr >= len);
//
//    // if state not changed then header data is not yet fully retrieved
//    // from network, just advance and retry later when we have more incoming data
//    needMoreData := (httpData.state = hpsReadingHeader)
//end;
//
//procedure parseHttpBodyUrlEncoded(tmp: string; len, expecteBodyLen: integer; var httpData: THttpData; var idx: integer; var needMoreData: boolean);
//var idxBody: integer;
//begin
//    idxBody := idx;
//    repeat
//
//    until (httpData.state <> hpsReadingBody) or (idxBody >= len);
//
//    // if state not changed then body data is not yet fully retrieved
//    // from network, just advance and retry later when we have more incoming data
//    needMoreData := (httpData.state = hpsReadingBody)
//end;
//
//procedure parseHttpBodyMultipart(tmp: string; len, expecteBodyLen: integer; var httpData: THttpData; var idx: integer; var needMoreData: boolean);
//var idxBody: integer;
//begin
//    idxBody := idx;
//    repeat
//
//    until (httpData.state <> hpsReadingBody) or (idxBody >= len);
//
//    // if state not changed then body data is not yet fully retrieved
//    // from network, just advance and retry later when we have more incoming data
//    needMoreData := (httpData.state = hpsReadingBody)
//end;
//
//procedure parseHttpBody(tmp: string; len, expecteBodyLen: integer; var httpData: THttpData; var idx: integer; var needMoreData: boolean);
//begin
//    if httpData.headers['Content-Type'] = 'Multipart/Form-Data' then
//    begin
//
//    end;
//end;
//
//procedure parseHttp(tmp: string; len:integer; var httpData: THttpData);
//var idx, expectedBodyLen : integer;
//    needMoreData: boolean;
//begin
//    needMoreData := false;
//    expectedBodyLen := 0;
//    // string start at index = 1
//    idx := 1;
//    repeat
//        if httpData.state = hpsComplete then
//        begin
//            exit;
//        end;
//
//        if (idx <= len) and (httpData.state = hpsReadingVerb) then
//        begin
//            parseHttpVerb(tmp, len, httpData, idx, needMoreData);
//        end;
//
//        if (idx <= len) and (httpData.state = hpsReadingPath) then
//        begin
//            parseHttpRequestPath(tmp, len, httpData, idx, needMoreData);
//        end;
//
//        if (idx <= len) and (httpData.state = hpsReadingVersion) then
//        begin
//            parseHttpVersion(tmp, len, httpData, idx, needMoreData);
//        end;
//
//        if (idx <= len) and (httpData.state = hpsReadingHeader) then
//        begin
//            parseHttpHeader(tmp, len, httpData, idx, needMoreData);
//        end;
//
//        if (idx <= len) and (httpData.state = hpsReadingBody) then
//        begin
//            //expectedBodyLen := strToInt(httpData.headers['Content-Length']);
//            parseHttpBody(tmp, len, expectedBodyLen, httpData, idx, needMoreData);
//        end;
//    until (idx > len) or (httpData.state = hpsComplete) or needMoreData;
//end;

end.

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

interface

uses


   classes,
   sysutils,
   contnrs;

type
    THttpProcessingState = (
       hpsReadingVerb,
       hpsReadingPath,
       hpsReadingVersion,
       hpsReadingHeader,
       hpsReadingBody,
       hpsComplete
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
       httpVerb : string;
       requestPath: string;
       httpVersion : string;
       headers: TFPHashList;
       body: TStream;
       isMultipart: boolean;
       files: TUploadedFiles;
       isChunked: boolean;
       pos: integer;
    end;

procedure parseHttp(tmp: string; len:integer; var httpData: THttpData);

implementation

procedure parseHttpVerb(tmp: string; len:integer; var httpData: THttpData; var idx: integer; var needMoreData: boolean);
const MAX_VERB = 9;
var verbs : array[0..MAX_VERB - 1] of string;
    idxVerb, verbLen, idxV, tmpIdxV, idxchar, idxComp: integer;
    verbMatched: boolean;
begin
    verbs[0] := 'GET';
    verbs[1] := 'POST';
    verbs[2] := 'DELETE';
    verbs[3] := 'PATCH';
    verbs[4] := 'PUT';
    verbs[5] := 'HEAD';
    verbs[6] := 'OPTIONS';
    verbs[7] := 'CONNECT';
    verbs[8] := 'TRACE';
    idxVerb := 0;
    idxV := idx;
    needMoreData := false;
    repeat
        if idxV > len then
        begin
            exit;
        end;

        if tmp[idxV] = ' ' then
        begin
            inc(idxV);
            inc(idx);
        end else
        begin
            repeat
                tmpIdxV := idxV;
                idxComp := 1;
                verbLen := length(verbs[idxVerb]);

                // assumed matched if incoming data from client is longer than
                // verb length otherwise not matched
                verbMatched := (len >= verbLen);

                if not verbMatched then
                begin
                    // definitely not matched, no need to check further.
                    // continue to next verb
                    inc(idxVerb);
                    continue;
                end;

                repeat
                    if uppercase(tmp[idxV]) <> verbs[idxVerb][idxComp] then
                    begin
                        verbMatched := false;
                        break;
                    end else
                    begin
                        inc(idxV);
                        inc(idxComp);
                    end;
                until ((idxV > len) or (idxComp > verbLen)) and (len >= verbLen);

                if verbMatched then
                begin
                    httpData.httpVerb := verbs[idxVerb];
                    httpData.state := hpsReadingPath;
                    idx := idxV;
                    exit;
                end;

                if (idxV > len) then
                begin
                    break;
                end;
                idxV := tmpIdxV;
                inc(idxVerb);
            until (idxVerb >= MAX_VERB);
        end;
    until (idxV > len) or (idxVerb >= MAX_VERB);

    // if state not changed then verb data is not yet fully retrieved
    // from network, just advance and retry later when we have more data coming
    needMoreData := (httpData.state = hpsReadingVerb)
end;

procedure parseHttpRequestPath(tmp: string; len:integer; var httpData: THttpData; var idx: integer; var needMoreData: boolean);
var idxPath: integer;
begin
    needMoreData := false;
    idxPath := idx;
    repeat
        // skip space
        if tmp[idxPath] = ' ' then
        begin
            inc(idx);
            inc(idxPath);
            continue;
        end;

        if tmp[idxPath] <> ' ' then
        begin
            inc(idxPath);
        end else
        begin
            httpData.requestPath:= copy(tmp, idx, idxPath - idx);
            httpData.state := hpsReadingVersion;
            idx := idxPath;
        end;
    until (httpData.state <> hpsReadingPath) or (idxPath >= len);

    // if state not changed then request path data is not yet fully retrieved
    // from network, just advance and retry later when we have more data coming
    needMoreData := (httpData.state = hpsReadingPath)
end;

procedure parseHttpVersion(tmp: string; len:integer; httpData: THttpData; var idx: integer; var needMoreData: boolean);
var idxVer: integer;
begin
    idxVer := idx;
    repeat
        if tmp[idxVer] = ' ' then
        begin
            // skip space
            inc(idx);
            inc(idxVer);
            continue;
        end;

        if tmp[idxVer] <> #13 then
        begin
            inc(idxVer);
        end else
        begin
            httpData.httpVersion:= copy(tmp, idx, idxVer - idx);
            httpData.state := hpsReadingHeader;
            idx := idxVer + 1; //+1 because at the end there is CRLF
        end;
    until (httpData.state <> hpsReadingVersion) or (idxVer >= len);

    // if state not changed then version data is not yet fully retrieved
    // from network, just advance and retry later when we have more incoming data
    needMoreData := (httpData.state = hpsReadingVersion)
end;

procedure parseHttpHeader(tmp: string; len:integer; var httpData: THttpData; var idx: integer; var needMoreData: boolean);
var idxHdr: integer;
begin
    needMoreData := false;
    idxHdr := idx;
    repeat

    until (httpData.state <> hpsReadingHeader) or (idxHdr >= len);

    // if state not changed then header data is not yet fully retrieved
    // from network, just advance and retry later when we have more incoming data
    needMoreData := (httpData.state = hpsReadingHeader)
end;

procedure parseHttpBodyUrlEncoded(tmp: string; len, expecteBodyLen: integer; var httpData: THttpData; var idx: integer; var needMoreData: boolean);
var idxBody: integer;
begin
    idxBody := idx;
    repeat

    until (httpData.state <> hpsReadingBody) or (idxBody >= len);

    // if state not changed then body data is not yet fully retrieved
    // from network, just advance and retry later when we have more incoming data
    needMoreData := (httpData.state = hpsReadingBody)
end;

procedure parseHttpBodyMultipart(tmp: string; len, expecteBodyLen: integer; var httpData: THttpData; var idx: integer; var needMoreData: boolean);
var idxBody: integer;
begin
    idxBody := idx;
    repeat

    until (httpData.state <> hpsReadingBody) or (idxBody >= len);

    // if state not changed then body data is not yet fully retrieved
    // from network, just advance and retry later when we have more incoming data
    needMoreData := (httpData.state = hpsReadingBody)
end;

procedure parseHttpBody(tmp: string; len, expecteBodyLen: integer; var httpData: THttpData; var idx: integer; var needMoreData: boolean);
begin
    if httpData.headers.Find('Content-Type') = 'Multipart/Form-Data' then
    begin

    end;
end;

procedure parseHttp(tmp: string; len:integer; var httpData: THttpData);
var idx, expectedBodyLen : integer;
    needMoreData: boolean;
begin
    needMoreData := false;
    expectedBodyLen := 0;
    // string start at index = 1
    idx := 1;
    repeat
        if httpData.state = hpsComplete then
        begin
            exit;
        end;

        if (idx <= len) and (httpData.state = hpsReadingVerb) then
        begin
            parseHttpVerb(tmp, len, httpData, idx, needMoreData);
        end;

        if (idx <= len) and (httpData.state = hpsReadingPath) then
        begin
            parseHttpRequestPath(tmp, len, httpData, idx, needMoreData);
        end;

        if (idx <= len) and (httpData.state = hpsReadingVersion) then
        begin
            parseHttpVersion(tmp, len, httpData, idx, needMoreData);
        end;

        if (idx <= len) and (httpData.state = hpsReadingHeader) then
        begin
            parseHttpHeader(tmp, len, httpData, idx, needMoreData);
        end;

        if (idx <= len) and (httpData.state = hpsReadingBody) then
        begin
            //expectedBodyLen := strToInt(httpData.headers['Content-Length']);
            parseHttpBody(tmp, len, expectedBodyLen, httpData, idx, needMoreData);
        end;
    until (idx > len) or (httpData.state = hpsComplete) or needMoreData;
end;

end.

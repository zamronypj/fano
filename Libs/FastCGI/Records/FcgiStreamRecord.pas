{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FcgiStreamRecord;

interface

{$MODE OBJFPC}
{$H+}

type

    (*!-----------------------------------------------
     * base class for stream record (FCGI_STDIN, FCGI_STDOUT, FCGI_STDERR)
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiStreamRecord = class(TFcgiRecord)
    private
        (*!------------------------------------------------
        * calculate numuber of bytes to write per record
        *-----------------------------------------------
        * @param len, current data length
        * @param excess, current data length excess
        * @return number of bytes actually written
        *-----------------------------------------------*)
        function getLengthToWrite(const len: integer; const excess : word) : word;

        (*!------------------------------------------------
        * calculate number of bytes in padding to write per record
        *-----------------------------------------------
        * @param len, current data length
        * @param excess, current data length excess
        * @return number of bytes actually written
        *-----------------------------------------------*)
        function getPaddingToWrite(const len: word) : byte;
    public
        constructor create(
            const aType : byte;
            const requestId : word;
            const content : string = ''
        );

        (*!------------------------------------------------
        * write record data to stream
        *-----------------------------------------------
        * @param stream, stream instance where to write
        * @return number of bytes actually written
        *-----------------------------------------------*)
        function write(const stream : IStreamAdapter) : integer; override;
    end;

implementation

uses

    fastcgi;

    constructor TFcgiStreamRecord.create(
        const aType : byte;
        const requestId : word;
        const content : string = ''
    );
    begin
        inherited create(aType, requestId);
        fContentData := content;
    end;

    (*!------------------------------------------------
    * calculate numuber of bytes to write per record
    *-----------------------------------------------
    * @param len, current data length
    * @param excess, current data length excess
    * @return number of bytes actually written
    *-----------------------------------------------*)
    function TFcgiStreamRecord.getLengthToWrite(const len: integer; const excess : word) : word;
    const MAX_LENGTH = $EFFF;
    begin
        if (len - excess) > MAX_LENGTH then
        begin
            result := MAX_LENGTH;
        end else
        begin
            result := len - excess;
        end;
    end;

    (*!------------------------------------------------
    * calculate numuber of bytes to write per record
    *-----------------------------------------------
    * @param len, current data length
    * @param excess, current data length excess
    * @return number of bytes actually written
    *-----------------------------------------------*)
    function TFcgiStreamRecord.getPaddingToWrite(const len: word) : byte;
    const MAX_LENGTH = $EFFF;
    begin
        if ((len mod FCGI_HEADER_LEN) = 0) then
        begin
            result := 0;
        end else
        begin
            result := FCGI_HEADER_LEN - (len mod FCGI_HEADER_LEN);
        end;
    end;

    (*!------------------------------------------------
    * write record data to stream
    *-----------------------------------------------
    * @param stream, stream instance where to write
    * @return number of bytes actually written
    *-----------------------------------------------*)
    function TFcgiStreamRecord.write(const stream : IStreamAdapter) : integer;
    var len : integer;
        indx, contenLen, bytesToWrite : word;
        contentRec : PFCGI_ContentRecord;
        padding : byte;
    begin
        len := length(fContentData);
        indx := 0;
        contenLen := 0;
        repeat
            contenLen := getLengthToWrite(len, indx);
            padding : getPaddingToWrite(contenLen);
            bytesToWrite := FCGI_HEADER_LEN + contentLen + padding;
            getMem(contentRec, bytesToWrite);
            try
                contentRec^.header.version := fVersion;
                contentRec^.header.reqtype := fType;
                contentRec^.header.paddingLength := padding;
                contentRec^.header.contentLength := NtoBE(contentLen);
                contentRec^.header.requestId := NToBE(fRequestID);
                move(fContentData[indx + 1], contentRec^.ContentData, contentLen);
                stream.writeBuffer(contentRec, bytesToWrite);
                inc(indx, contentLen);
            finally
                freeMem(contentRec, bytesToWrite);
            end;
        until (indx = len);
    end;
end.

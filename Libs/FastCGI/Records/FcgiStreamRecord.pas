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

uses

    FcgiRecord,
    StreamAdapterIntf;

type

    (*!-----------------------------------------------
     * base class for stream record (FCGI_STDIN, FCGI_STDOUT, FCGI_STDERR)
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiStreamRecord = class(TFcgiRecord)
    private
        (*!------------------------------------------------
        * calculate number of bytes to write per record
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

        (*!------------------------------------------------
        * write record data to stream
        *-----------------------------------------------
        * @param stream, stream instance where to write
        * @return number of bytes actually written
        *-----------------------------------------------*)
        function write(const stream : IStreamAdapter) : integer; override;
    end;

    TFcgiStreamRecordClass = class of TFcgiStreamRecord;

implementation

uses

    fastcgi;

    (*!------------------------------------------------
     * calculate number of bytes of padding to write
     *-----------------------------------------------
     * @param len, current data length
     * @return number of bytes required for padding
     *-----------------------------------------------*)
    function TFcgiStreamRecord.getPaddingToWrite(const len: word) : byte;
    var excessSize : byte;
    begin
        excessSize := len mod FCGI_HEADER_LEN;
        if (excessSize = 0) then
        begin
            //no padding needed
            result := 0;
        end else
        begin
            result := FCGI_HEADER_LEN - excessSize;
        end;
    end;

    (*!------------------------------------------------
    * write record data to stream
    *-----------------------------------------------
    * @param stream, stream instance where to write
    * @return number of bytes actually written
    *-----------------------------------------------*)
    function TFcgiStreamRecord.write(const stream : IStreamAdapter) : integer;
    var headerRec : FCGI_Header;
        padding : byte;
    begin
        headerRec.version := fVersion;
        headerRec.reqtype := fType;
        headerRec.requestId := NToBE(fRequestID);
        headerRec.contentLength := NtoBE(fContentLength);
        headerRec.paddingLength := getPaddingToWrite(fContentLength);
        headerRec.reserved := 0;
        stream.writeBuffer(headerRec, sizeof(FCGI_Header));
        stream.writeStream(fContentData);
        stream.writeBuffer(padding, headerRec.paddingLength);
        result := getRecordSize();
    end;
end.

{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FcgiGetValuesResult;

interface

{$MODE OBJFPC}
{$H+}

uses

    FcgiRecord,
    StreamAdapterIntf;

type

    (*!-----------------------------------------------
     * Get Values Result record (FCGI_GET_VALUES_RESULT)
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiGetValuesResult = class(TFcgiRecord)
    public
        constructor create(const requestId : word);

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

    constructor TFcgiGetValuesResult.create(const requestId : word);
    begin
        inherited create(FCGI_GET_VALUES_RESULT, requestId);
    end;

    (*!------------------------------------------------
    * write record data to stream
    *-----------------------------------------------
    * @param stream, stream instance where to write
    * @return number of bytes actually written
    *-----------------------------------------------*)
    function TFcgiGetValuesResult.write(const stream : IStreamAdapter) : integer;
    var rec : FCGI_Header;
        bytesToWrite : integer;
    begin
        fillChar(rec, sizeOf(FCGI_Header), 0);
        rec.version:= fVersion;
        rec.reqtype:= fType;
        rec.contentLength:= NtoBE(fContentLength);
        rec.paddingLength:= fPaddingLength;
        rec.requestId:= NToBE(fRequestId);
        bytesToWrite := getRecordSize();
        stream.writeBuffer(rec, bytesToWrite);
        result := bytesToWrite;
    end;
end.

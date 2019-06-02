{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FcgiGetValues;

interface

{$MODE OBJFPC}
{$H+}

uses

    FcgiRecord,
    StreamAdapterIntf;

type

    (*!-----------------------------------------------
     * Get Values record (FCGI_GET_VALUES)
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiGetValues = class(TFcgiRecord)
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

    constructor TFcgiGetValues.create(const requestId : word);
    begin
        inherited create(FCGI_GET_VALUES, requestId);
    end;

    (*!------------------------------------------------
    * write record data to stream
    *-----------------------------------------------
    * @param stream, stream instance where to write
    * @return number of bytes actually written
    *-----------------------------------------------*)
    function TFcgiGetValues.write(const stream : IStreamAdapter) : integer;
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

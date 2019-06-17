{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FcgiUnknownType;

interface

{$MODE OBJFPC}
{$H+}

uses

    StreamAdapterIntf,
    FcgiRecord;

type

    (*!-----------------------------------------------
     * Unknown type record (FCGI_UNKNOWN_TYPE)
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiUnknownType = class(TFcgiRecord)
    private
        fUnknownType : byte;
    public
        constructor create(
            const stream : IStreamAdapter;
            const requestId : word;
            const unknownType : byte
        );

        constructor createFromStream(const stream : IStreamAdapter);

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

    constructor TFcgiUnknownType.create(
        const stream : IStreamAdapter;
        const requestId : word;
        const unknownType : byte
    );
    begin
        inherited create(stream, FCGI_UNKNOWN_TYPE, requestId);
        if (stream.size() > 0) then
        begin
            //stream contain data, read from it instead
            initFromStream(stream);
        end else
        begin
            fUnknownType := unknownType;
        end;
    end;

    procedure TFcgiUnknownType.initFromStream(const stream : IStreamAdapter);
    var reqBody : FCGI_UnknownTypeBody;
    begin
        //skip header as parent class already read it
        stream.seek(sizeof(FCGI_Header));
        stream.readBuffer(reqBody, sizeof(FCGI_UnknownTypeBody));
        fUnknownType := reqBody._type;
    end;

    (*!------------------------------------------------
    * write record data to stream
    *-----------------------------------------------
    * @param stream, stream instance where to write
    * @return number of bytes actually written
    *-----------------------------------------------*)
    function TFcgiUnknownType.write(const stream : IStreamAdapter) : integer;
    var rec : FCGI_UnknownTypeRecord;
        bytesToWrite : integer;
    begin
        fillChar(rec, sizeOf(FCGI_UnknownTypeRecord), 0);
        rec.header.version:= fVersion;
        rec.header.reqtype:= fType;
        rec.header.contentLength:= NtoBE(fContentLength);
        rec.header.paddingLength:= fPaddingLength;
        rec.header.requestId:= NToBE(fRequestId);
        rec.body._type := fUnknownType;
        bytesToWrite := getRecordSize();
        stream.writeBuffer(rec, bytesToWrite);
        result := bytesToWrite;
    end;
end.

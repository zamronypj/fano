{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit BinaryResponseImpl;

interface

{$MODE OBJFPC}
{$H+}

uses
    ResponseIntf,
    ResponseStreamIntf,
    HeadersIntf,
    CloneableIntf;

type
    (*!------------------------------------------------
     * base binary response class such image
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TBinaryResponse = class(TInterfacedObject, IResponse, ICloneable)
    private
        httpHeaders : IHeaders;
        contentType : string;
        responseBody : IResponseStream;
        procedure writeToStdOutput(const respBody : IResponseStream);
    public
        constructor create(
            const hdrs : IHeaders;
            const contentType : string;
            const respBody : IResponseStream
        );
        destructor destroy(); override;

        (*!------------------------------------
         * get http headers instance
         *-------------------------------------
         * @return header instance
         *-------------------------------------*)
        function headers() : IHeaders;

        function write() : IResponse;
        function clone() : ICloneable;

        (*!------------------------------------
         * get response body
         *-------------------------------------
         * @return response body
         *-------------------------------------*)
        function body() : IResponseStream;
    end;

implementation

uses

    classes,
    sysutils;

const

    BUFFER_SIZE = 8 * 1204;

    constructor TBinaryResponse.create(
        const hdrs : IHeaders;
        const strContentType : string;
        const respBody : IResponseStream
    );
    begin
        httpHeaders := hdrs;
        contentType := strContentType;
        responseBody := respBody;
    end;

    destructor TBinaryResponse.destroy();
    begin
        inherited destroy();
        httpHeaders := nil;
        responseBody := nil;
    end;

    (*!------------------------------------
     * get http headers instance
     *-------------------------------------
     * @return header instance
     *-------------------------------------*)
    function TBinaryResponse.headers() : IHeaders;
    begin
        result := httpHeaders;
    end;

    (*!------------------------------------
     * read response body and output it to
     * standard output
     *-------------------------------------
     * @param respBody response stream to output
     *-------------------------------------*)
    procedure TBinaryResponse.writeToStdOutput(const respBody : IResponseStream);
    var numBytesRead: longint;
        handleStream : THandleStream;
        buff : array [0..BUFFER_SIZE-1] of byte;
    begin
        handleStream := THandleStream.create(getFileHandle(Output));
        try
            respBody.seek(0);
            //binary stream maybe big in size, so read in loop
            //by using smaller buffer to avoid consuming too much resource
            repeat
                numBytesRead := respBody.read(buff, BUFFER_SIZE);
                handleStream.write(buff, numBytesRead);
            until (numBytesRead < BUFFER_SIZE);
        finally
            handleStream.free();
        end;
    end;

    function TBinaryResponse.write() : IResponse;
    begin
        httpHeaders.setHeader('Content-Type', contentType);
        httpHeaders.setHeader('Content-Length', intToStr(responseBody.size()));
        httpHeaders.writeHeaders();
        writeToStdOutput(responseBody);
        result := self;
    end;

    function TBinaryResponse.clone() : ICloneable;
    var clonedObj : IResponse;
    begin
        clonedObj := TBinaryResponse.create(
            httpHeaders.clone() as IHeaders,
            contentType,
            //not clone response body as they may be big in size
            responseBody
        );
        result := clonedObj;
    end;

    (*!------------------------------------
     * get response body
     *-------------------------------------
     * @return response body
     *-------------------------------------*)
    function TBinaryResponse.body() : IResponseStream;
    begin
        result := responseBody;
    end;
end.

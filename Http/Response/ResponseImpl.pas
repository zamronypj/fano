{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ResponseImpl;

interface

{$MODE OBJFPC}
{$H+}

uses
    EnvironmentIntf,
    ResponseIntf,
    HeadersIntf,
    ResponseStreamIntf,
    CloneableIntf;

const

    BUFFER_SIZE = 8 * 1024;

type
    (*!------------------------------------------------
     * base Http response class
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TResponse = class(TInterfacedObject, IResponse, ICloneable)
    private
        webEnvironment : ICGIEnvironment;
        httpHeaders : IHeaders;
        bodyStream : IResponseStream;
        procedure writeToStdOutput(const respBody : IResponseStream);
    public
        constructor create(
            const env : ICGIEnvironment;
            const hdrs : IHeaders;
            const body : IResponseStream
        );
        destructor destroy(); override;

        (*!------------------------------------
         * get http headers instance
         *-------------------------------------
         * @return header instance
         *-------------------------------------*)
        function headers() : IHeaders;

        (*!------------------------------------
         * output http response to STDIN
         *-------------------------------------
         * @return current instance
         *-------------------------------------*)
        function write() : IResponse;

        (*!------------------------------------
         * get response body
         *-------------------------------------
         * @return response body
         *-------------------------------------*)
        function body() : IResponseStream;

        function clone() : ICloneable;
    end;

implementation

uses
    SysUtils;

    constructor TResponse.create(
        const env : ICGIEnvironment;
        const hdrs : IHeaders;
        const body : IResponseStream
    );
    begin
        webEnvironment := env;
        httpHeaders := hdrs;
        bodyStream := body;
    end;

    destructor TResponse.destroy();
    begin
        inherited destroy();
        webEnvironment := nil;
        httpHeaders := nil;
        bodyStream := nil
    end;

    (*!------------------------------------
     * get http headers instance
     *-------------------------------------
     * @return header instance
     *-------------------------------------*)
    function TResponse.headers() : IHeaders;
    begin
        result := httpHeaders;
    end;

    (*!------------------------------------
     * read response body and output it to
     * standard output
     *-------------------------------------
     * @param respBody response stream to output
     *-------------------------------------*)
    procedure TResponse.writeToStdOutput(const respBody : IResponseStream);
    var numBytesRead: longint;
        buff : string;
        handle : THandle;
    begin
        handle := getFileHandle(Output);
        setLength(buff, BUFFER_SIZE);
        respBody.seek(0);
        //stream maybe big in size, so read in loop
        //by using smaller buffer to avoid consuming too much resource
        repeat
            numBytesRead := respBody.read(buff[1], BUFFER_SIZE);
            blockWrite(handle, buff[1], numBytesRead);
        until (numBytesRead < BUFFER_SIZE);
    end;

    function TResponse.write() : IResponse;
    begin
        httpHeaders.writeHeaders();
        writeToStdOutput(bodyStream);
        result := self;
    end;

    function TResponse.clone() : ICloneable;
    var clonedObj : IResponse;
    begin
        clonedObj := TResponse.create(
            webEnvironment,
            httpHeaders.clone() as IHeaders,
            //TODO : do we need to create new instance?
            //response stream may contain big data
            //so just pass the current stream (for now)
            bodyStream
        );
        //TODO : copy any property
        result := clonedObj;
    end;

    (*!------------------------------------
     * get response body
     *-------------------------------------
     * @return response body
     *-------------------------------------*)
    function TResponse.body() : IResponseStream;
    begin
        result := bodyStream;
    end;
end.

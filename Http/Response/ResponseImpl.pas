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
    CloneableIntf,
    BaseResponseImpl;

type
    (*!------------------------------------------------
     * base Http response class
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TResponse = class(TBaseResponse)
    private
        webEnvironment : ICGIEnvironment;
    public
        constructor create(
            const env : ICGIEnvironment;
            const hdrs : IHeaders;
            const bodyStrs : IResponseStream
        );
        destructor destroy(); override;

        function clone() : ICloneable; override;
    end;

implementation

    constructor TResponse.create(
        const env : ICGIEnvironment;
        const hdrs : IHeaders;
        const bodyStrs : IResponseStream
    );
    begin
        inherited create(hdrs, bodyStrs);
        webEnvironment := env;
    end;

    destructor TResponse.destroy();
    begin
        inherited destroy();
        webEnvironment := nil;
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
end.

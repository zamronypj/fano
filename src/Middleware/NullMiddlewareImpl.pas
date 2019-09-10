{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit NullMiddlewareImpl;

interface

{$MODE OBJFPC}

uses

    RequestIntf,
    ResponseIntf,
    MiddlewareIntf,
    InjectableObjectImpl;

type

    (*!------------------------------------------------
     * null midlleware class
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TNullMiddleware = class(TInjectableObject, IMiddleware)
    public
        function handleRequest(
            const request : IRequest;
            const response : IResponse;
            var canContinue : boolean
        ) : IResponse;
    end;

implementation

    function TNullMiddleware.handleRequest(
        const request : IRequest;
        const response : IResponse;
        var canContinue : boolean
    ) : IResponse;
    begin
        //intentionally does nothing
        result := response;
    end;
end.

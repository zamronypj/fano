{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit SimpleDispatcherImpl;

interface

{$MODE OBJFPC}

uses

    EnvironmentIntf,
    ResponseIntf,
    StdInIntf,
    BaseDispatcherImpl;

type
    (*!------------------------------------------------
     * simple dispatcher implementation without
     * middleware support. It is faster than
     * TDispatcher because it does not process middlewares
     * stack during dispatching request
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TSimpleDispatcher = class(TBaseDispatcher)
    public
        function dispatchRequest(
            const env: ICGIEnvironment;
            const stdIn : IStdIn
        ) : IResponse; override;
    end;

implementation

    function TSimpleDispatcher.dispatchRequest(
        const env: ICGIEnvironment;
        const stdIn : IStdIn
    ) : IResponse;
    begin
        result := getRouteHandler(env).handleRequest(
            requestFactory.build(env, stdIn),
            responseFactory.build(env)
        );
    end;
end.

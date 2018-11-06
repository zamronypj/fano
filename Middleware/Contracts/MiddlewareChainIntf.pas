{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit MiddlewareChainIntf;

interface

{$MODE OBJFPC}

uses

   RequestIntf,
   ResponseIntf,
   RequestHandlerIntf;

type

    (*!------------------------------------------------
     * interface for any class having capability to
     * stack several middlewares and call
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IMiddlewareChain = interface
        ['{47B9A178-4A0A-4599-AD67-C73B8E42B82A}']
        function execute(
            const request : IRequest;
            const response : IResponse;
            const requestHandler : IRequestHandler
        ) : IResponse;
    end;

implementation
end.

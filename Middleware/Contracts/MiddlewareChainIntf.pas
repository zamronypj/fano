{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}
unit MiddlewareChainIntf;

interface

uses
   RequestIntf,
   ResponseIntf,
   RequestHandlerIntf;

type
    {------------------------------------------------
     interface for any class having capability to
     stack several middlewares and call
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
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

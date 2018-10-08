{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}
unit MiddlewareIntf;

interface

uses
   RequestIntf,
   ResponseIntf;

type
    {------------------------------------------------
     interface for any class having capability as middleware
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IMiddleware = interface
        ['{E0ECB41C-8D8F-41C1-9FAC-7DFBD06ED8D4}']
        function handleRequest(
            const request : IRequest;
            const response : IResponse;
            var canContinue : boolean
        ) : IResponse;
    end;

implementation
end.

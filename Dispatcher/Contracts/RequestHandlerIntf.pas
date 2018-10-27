{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit RequestHandlerIntf;

interface

{$MODE OBJFPC}

uses

    RequestIntf,
    ResponseIntf;

type
    {------------------------------------------------
     interface for any class having capability handle
     request and return new response
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IRequestHandler = interface
        ['{483E0FAB-E1E6-4B8C-B193-F8615E039369}']
        function handleRequest(const request : IRequest; const response : IResponse) : IResponse;
    end;

implementation

end.

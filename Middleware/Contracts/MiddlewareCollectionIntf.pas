unit MiddlewareCollectionIntf;

interface

uses
   MiddlewareIntf;

type
    {------------------------------------------------
     interface for any class having capability to
     manage one or more middlewares
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IMiddlewareCollection = interface
        function add(const middleware : IMiddleware) : IMiddlewareCollection;
    end;

implementation
end.

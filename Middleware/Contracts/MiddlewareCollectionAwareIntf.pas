unit MiddlewareCollectionAwareIntf;

interface

uses
    MiddlewareIntf,
    MiddlewareCollectionIntf;

type
    {------------------------------------------------
     interface for any class having capability to contain
     middleware collection
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IMiddlewareCollectionAware = interface
        ['{4C62B73D-C6D8-47BB-B8C0-EBF4EC3DDCB7}']
        function addBeforeMiddleware(const middleware : IMiddleware) : IMiddlewareCollectionAware;
        function addAfterMiddleware(const middleware : IMiddleware) : IMiddlewareCollectionAware;
        function getBeforeMiddlewares() : IMiddlewareCollection;
        function getAfterMiddlewares() : IMiddlewareCollection;
    end;

implementation
end.

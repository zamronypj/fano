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
        function addBefore(const middleware : IMiddleware) : IMiddlewareCollectionAware;
        function addAfter(const middleware : IMiddleware) : IMiddlewareCollectionAware;
        function getBefore() : IMiddlewareCollection;
        function getAfter() : IMiddlewareCollection;
    end;

implementation
end.

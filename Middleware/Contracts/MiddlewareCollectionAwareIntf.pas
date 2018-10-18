unit MiddlewareCollectionAwareIntf;

interface

uses
    MiddlewareIntf,
    MiddlewareCollectionIntf;

type
    (*!------------------------------------------------
     * interface for any class having capability to contain
     * middleware collection
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    IMiddlewareCollectionAware = interface
        ['{4C62B73D-C6D8-47BB-B8C0-EBF4EC3DDCB7}']

        (*!------------------------------------------------
         * Add middleware to list of middleware that is
         * executed before actual route handler
         * ------------------------------------------------
         * @param middleware middleware to add
         * @return current middleware collection aware instance
         *-------------------------------------------------*)
        function addBefore(const middleware : IMiddleware) : IMiddlewareCollectionAware;

        (*!------------------------------------------------
         * Add middleware to list of middleware that is
         * executed after actual route handler
         * ------------------------------------------------
         * @param middleware middleware to add
         * @return current middleware collection aware instance
         *-------------------------------------------------*)
        function addAfter(const middleware : IMiddleware) : IMiddlewareCollectionAware;

        (*!------------------------------------------------
         * get list of middleware that is
         * executed before actual route handler
         * ------------------------------------------------
         * @return instance of IMiddlewareCollection
         *-------------------------------------------------*)
        function getBefore() : IMiddlewareCollection;

        (*!------------------------------------------------
         * get list of middleware that is
         * executed before actual route handler
         * ------------------------------------------------
         * @return instance of IMiddlewareCollection
         *-------------------------------------------------*)
        function getAfter() : IMiddlewareCollection;
    end;

implementation
end.

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
        ['{DF2C4336-6849-4A50-AACE-3676CD9FB395}']
        function add(const middleware : IMiddleware) : IMiddlewareCollection;
    end;

implementation
end.

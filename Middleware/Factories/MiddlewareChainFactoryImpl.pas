unit MiddlewareChainFactoryImpl;

interface

uses
   MiddlewareChainIntf,
   MiddlewareChainFactoryIntf,
   MiddlewareCollectionIntf;

type
    {*!
     basic class having capability to create
     middleware chain instance

     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    *}
    TMiddlewareChainFactory = class(TInterfacedObject, IMiddlewareChainFactory)
    public
        function build(const collection : IMiddlewareCollection) : IMiddlewareChain;
    end;

implementation

uses
    MiddlewareChainImpl;

    function TMiddlewareChainFactory.build(const collection : IMiddlewareCollection) : IMiddlewareChain;
    begin
        result := TMiddlewareChain.create(collection);
    end;
end.

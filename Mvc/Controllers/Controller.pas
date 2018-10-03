unit Controller;

interface

uses
    ResponseIntf,
    RequestIntf,
    RouteHandlerIntf;

type

    TController = class(TInterfacedObject, IRouteHandler)
    private
    public
        function handleRequest(
              const request : IRequest;
              const response : IResponse
        ) : IResponse; virtual; abstract;
    end;

implementation

end.

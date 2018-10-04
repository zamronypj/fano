unit ControllerImpl;

interface

uses
    ResponseIntf,
    RequestIntf,
    RouteHandlerIntf,
    ViewIntf;

type

    TController = class(TInterfacedObject, IRouteHandler)
    protected
        gView : IView;
    public
        constructor create(const viewInst : IView);
        destructor destroy(); override;
        function handleRequest(
              const request : IRequest;
              const response : IResponse
        ) : IResponse; virtual; abstract;
    end;

implementation

    constructor TController.create(const viewInst : IView);
    begin
        gView := viewInst;
    end;

    destructor TController.destroy();
    begin
        gView := nil;
    end;

end.

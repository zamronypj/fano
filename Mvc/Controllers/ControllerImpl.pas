unit ControllerImpl;

interface

uses
    ResponseIntf,
    RequestIntf,
    RouteHandlerIntf,
    RouteHandlerImpl,
    MiddlewareCollectionIntf,
    ViewIntf,
    ViewParametersIntf;

type

    TController = class(TRouteHandler)
    protected
        gView : IView;
        viewParams : IViewParameters;
    public
        constructor create(
            const beforeMiddlewares : IMiddlewareCollection;
            const afterMiddlewares : IMiddlewareCollection;
            const viewInst : IView;
            const viewParamsInst : IViewParameters
        );
        destructor destroy(); override;
    end;

implementation

    constructor TController.create(
        const beforeMiddlewares : IMiddlewareCollection;
        const afterMiddlewares : IMiddlewareCollection;
        const viewInst : IView;
        const viewParamsInst : IViewParameters
    );
    begin
        inherited create(beforeMiddlewares, afterMiddlewares);
        gView := viewInst;
        viewParams := viewParamsInst;
    end;

    destructor TController.destroy();
    begin
        inherited destroy();
        gView := nil;
        viewParams := nil;
    end;

end.

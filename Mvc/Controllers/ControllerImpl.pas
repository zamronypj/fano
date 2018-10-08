unit ControllerImpl;

interface

uses
    ResponseIntf,
    RequestIntf,
    RouteHandlerIntf,
    RouteHandlerImpl,
    MiddlewareCollectionIntf,
    ViewIntf,
    ViewParamsIntf;

type

    TController = class(TRouteHandler)
    protected
        gView : IView;
        viewParams : IViewParameters;
    public
        constructor create(
            const middlewares : IMiddlewareCollection;
            const viewInst : IView;
            const viewParamsInst : IViewParameters
        );
        destructor destroy(); override;
    end;

implementation

    constructor TController.create(
        const middlewares : IMiddlewareCollection;
        const viewInst : IView;
        const viewParamsInst : IViewParameters
    );
    begin
        inherited create(middlewares);
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

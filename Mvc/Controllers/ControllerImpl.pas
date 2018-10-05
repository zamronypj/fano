unit ControllerImpl;

interface

uses
    ResponseIntf,
    RequestIntf,
    RouteHandlerIntf,
    RouteHandlerImpl,
    ViewIntf,
    ViewParamsIntf;

type

    TController = class(TRouteHandler)
    protected
        gView : IView;
        viewParams : IViewParameters;
    public
        constructor create(
            const viewInst : IView;
            const viewParamsInst : IViewParameters
        );
        destructor destroy(); override;
    end;

implementation

    constructor TController.create(
        const viewInst : IView;
        const viewParamsInst : IViewParameters
    );
    begin
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

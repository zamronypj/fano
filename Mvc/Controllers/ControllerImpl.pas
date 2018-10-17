{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}

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

  (*!------------------------------------------------
   * basic controller implementation class
   *
   * @author Zamrony P. Juhara <zamronypj@yahoo.com>
   *-----------------------------------------------*)
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

        function handleRequest(
              const request : IRequest;
              const response : IResponse
        ) : IResponse; override;
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

    function TController.handleRequest(
          const request : IRequest;
          const response : IResponse
    ) : IResponse;
    begin
        result := gView.render(viewParams, response);
    end;

end.

{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ControllerImpl;

interface

{$MODE OBJFPC}

uses

    ResponseIntf,
    RequestIntf,
    RouteHandlerIntf,
    RouteHandlerImpl,
    MiddlewareCollectionAwareIntf,
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
            const aMiddlewares : IMiddlewareCollectionAware;
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
        const aMiddlewares : IMiddlewareCollectionAware;
        const viewInst : IView;
        const viewParamsInst : IViewParameters
    );
    begin
        inherited create(aMiddlewares);
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

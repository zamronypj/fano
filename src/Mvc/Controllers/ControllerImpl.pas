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
    RequestHandlerIntf,
    RouteArgsReaderIntf,
    MiddlewareCollectionAwareIntf,
    ViewIntf,
    ViewParametersIntf,
    InjectableObjectImpl;

type

    (*!------------------------------------------------
     * basic controller implementation class
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TController = class(TInjectableObject, IRequestHandler)
    protected
        gView : IView;
        viewParams : IViewParameters;
    public

        (*!-------------------------------------------
         * constructor
         *--------------------------------------------
         * @param viewInst view instance to use
         * @param viewParamsInt view parameters
         *--------------------------------------------*)
        constructor create(
            const viewInst : IView;
            const viewParamsInst : IViewParameters
        );

        (*!-------------------------------------------
         * destructor
         *--------------------------------------------*)
        destructor destroy(); override;

        (*!-------------------------------------------
         * handle request
         *--------------------------------------------
         * @param request object represent current request
         * @param response object represent current response
         * @param args object represent current route arguments
         * @return new response
         *--------------------------------------------*)
        function handleRequest(
            const request : IRequest;
            const response : IResponse;
            const args : IRouteArgsReader
        ) : IResponse; virtual;
    end;

implementation

    (*!-------------------------------------------
     * constructor
     *--------------------------------------------
     * @param amiddlewares object represent middlewares
     * @param viewInst view instance to use
     * @param viewParamsInt view parameters
     *--------------------------------------------*)
    constructor TController.create(
        const viewInst : IView;
        const viewParamsInst : IViewParameters
    );
    begin
        gView := viewInst;
        viewParams := viewParamsInst;
    end;

    (*!-------------------------------------------
     * destructor
     *--------------------------------------------*)
    destructor TController.destroy();
    begin
        gView := nil;
        viewParams := nil;
        inherited destroy();
    end;

    (*!-------------------------------------------
     * handle request
     *--------------------------------------------
     * @param request object represent current request
     * @param response object represent current response
     * @return new response
     *--------------------------------------------*)
    function TController.handleRequest(
        const request : IRequest;
        const response : IResponse;
        const args : IRouteArgsReader
    ) : IResponse;
    begin
        result := gView.render(viewParams, response);
    end;

end.

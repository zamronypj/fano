{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit CompositeViewImpl;

interface

uses

    DependencyIntf,
    ResponseIntf,
    ViewIntf,
    ViewParametersIntf,
    InjectableObjectImpl;

type

    (*!-----------------------------------------------
     * view that is compose from several views
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *------------------------------------------------*)
    TCompositeView = class(TInjectableObject, IView)
    private
        firstView : IView;
        secondView : IView;
    public
        constructor create(
            const firstViewInst : IView;
            const secondViewInst : IView
        );
        destructor destroy(); override;

        (*!------------------------------------------------
         * render view
         *------------------------------------------------
         * @param viewParams view parameters
         * @param response response instance
         * @return response
         *-----------------------------------------------*)
        function render(
            const viewParams : IViewParameters;
            const response : IResponse
        ) : IResponse;
    end;

implementation

    constructor TCompositeView.create(
        const firstViewInst : IView;
        const secondViewInst : IView
    );
    begin
        firstView := firstViewInst;
        secondView := secondViewInst;
    end;

    destructor TCompositeView.destroy();
    begin
        inherited destroy();
        firstView := nil;
        secondView := nil;
    end;

    (*!------------------------------------------------
     * render view
     *------------------------------------------------
     * @param viewParams view parameters
     * @param response response instance
     * @return response
     *-----------------------------------------------*)
    function TCompositeView.render(
        const viewParams : IViewParameters;
        const response : IResponse
    ) : IResponse;
    begin
        result := firstView.render(viewParams, response);
        result := secondView.render(viewParams, result);
    end;

end.

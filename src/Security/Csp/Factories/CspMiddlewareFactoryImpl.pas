{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2022 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit CspMiddlewareFactoryImpl;

interface

{$MODE OBJFPC}

uses

    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl,
    RequestHandlerIntf,
    CspConstant;

type

    (*!------------------------------------------------
     * factory class for TCspMiddleware
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TCspMiddlewareFactory = class(TFactory, IDependencyFactory)
    private
        fCspConfig: TCspConfig;
    public
        (*!---------------------------------------
         * constructor
         *----------------------------------------
         * @param CSP config
         * @return instance of factory
         *----------------------------------------*)
        constructor create(const cspConfig: TCspConfig); overload;

        (*!---------------------------------------
         * constructor
         *----------------------------------------
         * @return instance of factory
         *----------------------------------------*)
        constructor create(); overload;

        function initDefault() : TCspMiddlewareFactory;
        function defaultSrc(const aval : string) : TCspMiddlewareFactory;
        function scriptSrc(const aval : string) : TCspMiddlewareFactory;
        function childSrc(const aval : string) : TCspMiddlewareFactory;
        function connectSrc(const aval : string) : TCspMiddlewareFactory;
        function imgSrc(const aval : string) : TCspMiddlewareFactory;
        function baseUri(const aval : string) : TCspMiddlewareFactory;
        function frameSrc(const aval : string) : TCspMiddlewareFactory;
        function fontSrc(const aval : string) : TCspMiddlewareFactory;
        function styleSrc(const aval : string) : TCspMiddlewareFactory;
        function mediaSrc(const aval : string) : TCspMiddlewareFactory;
        function formAction(const aval : string) : TCspMiddlewareFactory;
        function frameAncestors(const aval : string) : TCspMiddlewareFactory;
        function reportUri(const aval : string) : TCspMiddlewareFactory;
        function objectSrc(const aval : string) : TCspMiddlewareFactory;
        function workerSrc(const aval : string) : TCspMiddlewareFactory;
        function upgradeInsecure(const aval : boolean) : TCspMiddlewareFactory;

        (*!---------------------------------------
         * build middleware instance
         *----------------------------------------
         * @param container dependency container
         * @return instance of middleware
         *----------------------------------------*)
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses

    CspMiddlewareImpl;

    constructor TCspMiddlewareFactory.create(const cspConfig: TCspConfig);
    begin
        fCspConfig := cspConfig;
    end;

    constructor TCspMiddlewareFactory.create();
    begin
        initDefault();
    end;

    function TCspMiddlewareFactory.initDefault() : TCspMiddlewareFactory;
    begin
        fCspConfig:= default(TCspConfig);
        fCspConfig.defaultSrc := CSP_SELF;
        result := self;
    end;

    function TCspMiddlewareFactory.defaultSrc(const aval : string) : TCspMiddlewareFactory;
    begin
        fCspConfig.defaultSrc := aval;
        result := self;
    end;

    function TCspMiddlewareFactory.scriptSrc(const aval : string) : TCspMiddlewareFactory;
    begin
        fCspConfig.scriptSrc := aval;
        result := self;
    end;

    function TCspMiddlewareFactory.childSrc(const aval : string) : TCspMiddlewareFactory;
    begin
        fCspConfig.childSrc := aval;
        result := self;
    end;

    function TCspMiddlewareFactory.connectSrc(const aval : string) : TCspMiddlewareFactory;
    begin
        fCspConfig.connectSrc := aval;
        result := self;
    end;

    function TCspMiddlewareFactory.imgSrc(const aval : string) : TCspMiddlewareFactory;
    begin
        fCspConfig.imgSrc := aval;
        result := self;
    end;

    function TCspMiddlewareFactory.baseUri(const aval : string) : TCspMiddlewareFactory;
    begin
        fCspConfig.baseUri := aval;
        result := self;
    end;

    function TCspMiddlewareFactory.frameSrc(const aval : string) : TCspMiddlewareFactory;
    begin
        fCspConfig.frameSrc := aval;
        result := self;
    end;

    function TCspMiddlewareFactory.fontSrc(const aval : string) : TCspMiddlewareFactory;
    begin
        fCspConfig.fontSrc := aval;
        result := self;
    end;

    function TCspMiddlewareFactory.styleSrc(const aval : string) : TCspMiddlewareFactory;
    begin
        fCspConfig.styleSrc := aval;
        result := self;
    end;

    function TCspMiddlewareFactory.mediaSrc(const aval : string) : TCspMiddlewareFactory;
    begin
        fCspConfig.mediaSrc := aval;
        result := self;
    end;

    function TCspMiddlewareFactory.formAction(const aval : string) : TCspMiddlewareFactory;
    begin
        fCspConfig.formAction := aval;
        result := self;
    end;

    function TCspMiddlewareFactory.frameAncestors(const aval : string) : TCspMiddlewareFactory;
    begin
        fCspConfig.frameAncestors := aval;
        result := self;
    end;

    function TCspMiddlewareFactory.reportUri(const aval : string) : TCspMiddlewareFactory;
    begin
        fCspConfig.reportUri := aval;
        result := self;
    end;

    function TCspMiddlewareFactory.objectSrc(const aval : string) : TCspMiddlewareFactory;
    begin
        fCspConfig.objectSrc := aval;
        result := self;
    end;

    function TCspMiddlewareFactory.workerSrc(const aval : string) : TCspMiddlewareFactory;
    begin
        fCspConfig.workerSrc := aval;
        result := self;
    end;

    function TCspMiddlewareFactory.upgradeInsecure(const aval : boolean) : TCspMiddlewareFactory;
    begin
        fCspConfig.upgradeInsecureRequests := aval;
        result := self;
    end;

    function TCspMiddlewareFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TCspMiddleware.create(fCspConfig);
    end;

end.

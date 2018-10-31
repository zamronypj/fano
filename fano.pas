{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit fano;

interface

{$MODE OBJFPC}

uses

    {*! -------------------------------
        unit interfaces
    ----------------------------------- *}
    DependencyContainerIntf,
    DependencyIntf,
    CloneableIntf,
    RunnableIntf,
    DispatcherIntf,
    RequestHandlerIntf,
    EnvironmentIntf,
    ErrorHandlerIntf,
    HashListIntf,
    DependencyListIntf,
    SerializeableIntf,
    AppIntf,
    HeadersIntf,
    RequestIntf,
    ResponseIntf,
    RouteMatcherIntf,
    RouteCollectionIntf,
    RouteHandlerIntf,
    MiddlewareCollectionAwareIntf,
    MiddlewareCollectionIntf,
    ConfigIntf,
    OutputBufferIntf,
    TemplateParserIntf,
    ViewIntf,
    ViewParametersIntf,
    LoggerIntf,

    {*! -------------------------------
        unit implementations
    ----------------------------------- *}
    DependencyContainerImpl,
    DependencyListImpl,
    EnvironmentImpl,
    EnvironmentFactoryImpl,
    ErrorHandlerImpl,
    EDependencyNotFoundImpl,
    EInvalidFactoryImpl,
    FactoryImpl,

    DispatcherFactoryImpl,
    SimpleDispatcherFactoryImpl,
    EInvalidDispatcherImpl,
    EMethodNotAllowedImpl,
    ERouteHandlerNotFoundImpl,

    AppImpl,
    RouteHandlerImpl,
    RouteCollectionFactoryImpl,
    SimpleRouteCollectionFactoryImpl,
    CombineRouteCollectionFactoryImpl,

    HeadersFactoryImpl,
    OutputBufferFactoryImpl,
    ErrorHandlerFactoryImpl,
    JsonResponseImpl,
    JsonFileConfigImpl,
    JsonFileConfigFactoryImpl,
    MiddlewareCollectionAwareFactoryImpl,
    NullMiddlewareCollectionAwareFactoryImpl,
    TemplateParserFactoryImpl,
    SimpleTemplateParserFactoryImpl,
    TemplateFileViewImpl,
    ViewParametersFactoryImpl,
    ControllerImpl,
    FileLoggerImpl,

    {*! -------------------------------
        data type unit
    ----------------------------------- *}
    KeyValueTypes,
    PlaceholderTypes;

type
    (*!-----------------------------------------------
     * Redeclare all classes in one unit to simplify
     * including classes in application code
     *-------------------------------------------------
     * If you use this unit, then you do not to include
     * other unit otherwise you will get compilation error
     * about duplicate identifier
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *------------------------------------------------*)

    //interface aliases
    IDependencyContainer = DependencyContainerIntf.IDependencyContainer;
    IDependencyFactory = DependencyContainerIntf.IDependencyFactory;
    IDependency = DependencyIntf.IDependency;
    ICloneable = CloneableIntf.ICloneable;
    IRunnable = RunnableIntf.IRunnable;
    IDispatcher = DispatcherIntf.IDispatcher;
    IRequestHandler = RequestHandlerIntf.IRequestHandler;
    ICGIEnvironment = EnvironmentIntf.ICGIEnvironment;
    IErrorHandler = ErrorHandlerIntf.IErrorHandler;
    IHashList = HashListIntf.IHashList;
    IDependencyList = DependencyListIntf.IDependencyList;
    ISerializeable = SerializeableIntf.ISerializeable;
    IRouteMatcher = RouteMatcherIntf.IRouteMatcher;
    IWebApplication = AppIntf.IWebApplication;
    IRouteCollection = RouteCollectionIntf.IRouteCollection;
    IRouteHandler = RouteHandlerIntf.IRouteHandler;
    IMiddlewareCollection = MiddlewareCollectionIntf.IMiddlewareCollection;
    IMiddlewareCollectionAware = MiddlewareCollectionAwareIntf.IMiddlewareCollectionAware;
    IAppConfiguration = ConfigIntf.IAppConfiguration;
    IOutputBuffer = OutputBufferIntf.IOutputBuffer;
    IHeaders = HeadersIntf.IHeaders;
    IRequest = RequestIntf.IRequest;
    IResponse = ResponseIntf.IResponse;
    IView = ViewIntf.IView;
    IViewParameters = ViewParametersIntf.IViewParameters;
    ITemplateParser = TemplateParserIntf.ITemplateParser;
    ILogger = LoggerIntf.ILogger;

    //implementation aliases
    TDependencyContainer = DependencyContainerImpl.TDependencyContainer;
    TDependencyList = DependencyListImpl.TDependencyList;
    TFactory = FactoryImpl.TFactory;
    EDependencyNotFound = EDependencyNotFoundImpl.EDependencyNotFound;
    EInvalidFactory = EInvalidFactoryImpl.EInvalidFactory;

    EInvalidDispatcher = EInvalidDispatcherImpl.EInvalidDispatcher;
    EMethodNotAllowed = EMethodNotAllowedImpl.EMethodNotAllowed;
    ERouteHandlerNotFound = ERouteHandlerNotFoundImpl.ERouteHandlerNotFound;

    TCGIEnvironment = EnvironmentImpl.TCGIEnvironment;
    TErrorHandler = ErrorHandlerImpl.TErrorHandler;
    TFanoWebApplication = AppImpl.TFanoWebApplication;
    TRouteHandler = RouteHandlerImpl.TRouteHandler;
    TController = ControllerImpl.TController;
    TJsonFileConfigFactory = JsonFileConfigFactoryImpl.TJsonFileConfigFactory;
    TNullMiddlewareCollectionAwareFactory = NullMiddlewareCollectionAwareFactoryImpl.TNullMiddlewareCollectionAwareFactory;
    TSimpleRouteCollectionFactory = SimpleRouteCollectionFactoryImpl.TSimpleRouteCollectionFactory;
    TSimpleDispatcherFactory = SimpleDispatcherFactoryImpl.TSimpleDispatcherFactory;
    THeadersFactory = HeadersFactoryImpl.THeadersFactory;
    TOutputBufferFactory = OutputBufferFactoryImpl.TOutputBufferFactory;
    TSimpleTemplateParserFactory = SimpleTemplateParserFactoryImpl.TSimpleTemplateParserFactory;
    TTemplateParserFactory = TemplateParserFactoryImpl.TTemplateParserFactory;
    TViewParametersFactory = ViewParametersFactoryImpl.TViewParametersFactory;
    TTemplateFileView = TemplateFileViewImpl.TTemplateFileView;
    TJsonResponse = JsonResponseImpl.TJsonResponse;
    TFileLogger = FileLoggerImpl.TFileLogger;

    TPlaceholder = PlaceholderTypes.TPlaceholder;
    TArrayOfPlaceholders = PlaceholderTypes.TArrayOfPlaceholders;
    TKeyValue = KeyValueTypes.TKeyValue;
    TArrayOfKeyValue = KeyValueTypes.TArrayOfKeyValue;

implementation

end.

{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (GPL 3.0)
 *}

(*! ---------------------------------------------
 * redeclare implementation aliases that is included in fano.pas unit
 * This file is provided so we can use fano framework
 * by using only one uses to simplify things.
 *
 * @author Zamrony P. Juhara <zamronypj@yahoo.com>
 *-----------------------------------------------*)

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
TAjaxErrorHandler = AjaxErrorHandlerImpl.TAjaxErrorHandler;
TFanoWebApplication = AppImpl.TFanoWebApplication;
TRouteHandler = RouteHandlerImpl.TRouteHandler;
TController = ControllerImpl.TController;
TJsonFileConfigFactory = JsonFileConfigFactoryImpl.TJsonFileConfigFactory;
TMiddlewareCollectionAwareFactory = MiddlewareCollectionAwareFactoryImpl.TMiddlewareCollectionAwareFactory;
TNullMiddlewareCollectionAwareFactory = NullMiddlewareCollectionAwareFactoryImpl.TNullMiddlewareCollectionAwareFactory;
TSimpleRouteCollectionFactory = SimpleRouteCollectionFactoryImpl.TSimpleRouteCollectionFactory;

TDispatcherFactory = DispatcherFactoryImpl.TDispatcherFactory;
TSimpleDispatcherFactory = SimpleDispatcherFactoryImpl.TSimpleDispatcherFactory;

THeadersFactory = HeadersFactoryImpl.THeadersFactory;
TOutputBufferFactory = OutputBufferFactoryImpl.TOutputBufferFactory;
TSimpleTemplateParserFactory = SimpleTemplateParserFactoryImpl.TSimpleTemplateParserFactory;
TTemplateParserFactory = TemplateParserFactoryImpl.TTemplateParserFactory;
TViewParametersFactory = ViewParametersFactoryImpl.TViewParametersFactory;
TTemplateFileView = TemplateFileViewImpl.TTemplateFileView;
TJsonResponse = JsonResponseImpl.TJsonResponse;

TFileLogger = FileLoggerImpl.TFileLogger;
TFileLoggerFactory = FileLoggerFactoryImpl.TFileLoggerFactory;
TNullLogger = NullLoggerImpl.TNullLogger;
TNullLoggerFactory = NullLoggerFactoryImpl.TNullLoggerFactory;

TPlaceholder = PlaceholderTypes.TPlaceholder;
TArrayOfPlaceholders = PlaceholderTypes.TArrayOfPlaceholders;
TKeyValue = KeyValueTypes.TKeyValue;
TArrayOfKeyValue = KeyValueTypes.TArrayOfKeyValue;

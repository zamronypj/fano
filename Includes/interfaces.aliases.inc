{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

(*! ---------------------------------------------
 * redeclare interface aliases that is included in fano.pas unit
 * This file is provided so we can use fano framework
 * by using only one uses to simplify things.
 *
 * @author Zamrony P. Juhara <zamronypj@yahoo.com>
 *-----------------------------------------------*)

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
IMiddleware = MiddlewareIntf.IMiddleware;
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

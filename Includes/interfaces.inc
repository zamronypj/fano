{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

(*! ---------------------------------------------
 * unit interfaces that is included in fano.pas unit
 * This file is provided so we can use fano framework
 * by using only one uses to simplify things.
 *
 * @author Zamrony P. Juhara <zamronypj@yahoo.com>
 *-----------------------------------------------*)
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
RouterIntf,
RouteCollectionIntf,
RouteHandlerIntf,
MiddlewareIntf,
MiddlewareCollectionAwareIntf,
MiddlewareCollectionIntf,
ConfigIntf,
OutputBufferIntf,
TemplateParserIntf,
ViewIntf,
ViewParametersIntf,
ModelDataIntf,
ModelWriterIntf,
ModelReaderIntf,
ModelPresenterIntf,
ModelPresenterAwareIntf,
LoggerIntf, //note: coma, instead of semicolon, is intentional

{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
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
LoggerIntf, //note: coma, instead of semicolon, is intentional

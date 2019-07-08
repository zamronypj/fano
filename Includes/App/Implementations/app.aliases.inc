{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

(*! ---------------------------------------------
 * redeclare all class types in unit inside App
 * directory
 *
 * @author Zamrony P. Juhara <zamronypj@yahoo.com>
 *-----------------------------------------------*)

TFanoWebApplication = AppImpl.TFanoWebApplication;
TSimpleWebApplication = SimpleAppImpl.TSimpleWebApplication;

{----------------Begin FastCGI related-----------------------------}

TInetSocketSvr = InetSocketSvrImpl.TInetSocketSvr;

{$IFDEF unix}
TUnixSocketSvr = UnixSocketSvrImpl.TUnixSocketSvr;
{$ENDIF}

TBoundSocketSvr = BoundSocketSvrImpl.TBoundSocketSvr;

TFastCGIWebApplication = FastCGIAppImpl.TFastCGIWebApplication;
TSimpleFastCGIWebApplication = SimpleFastCGIAppImpl.TSimpleFastCGIWebApplication;

{$IFDEF unix}
TSimpleUnixFastCGIWebApplication = SimpleUnixFastCGIAppImpl.TSimpleUnixFastCGIWebApplication;
{$ENDIF}

TSimpleSockFastCGIWebApplication = SimpleSockFastCGIAppImpl.TSimpleSockFastCGIWebApplication;

{----------------End FastCGI related-----------------------------}

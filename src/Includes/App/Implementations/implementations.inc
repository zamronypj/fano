{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

(*! ---------------------------------------------
 * implementation units for app
 * that is included in fano.pas unit
 *
 * @author Zamrony P. Juhara <zamronypj@yahoo.com>
 *-----------------------------------------------*)

AppImpl,
DaemonAppImpl,

BasicAppServiceProviderImpl,
DaemonAppServiceProviderImpl,
ServerAppServiceProviderImpl,

{----------------Begin FastCGI related-----------------------------}
FastCgiAppServiceProviderImpl,
{---------------- End FastCGI related-----------------------------}

{----------------Begin SCGI related-----------------------------}
ScgiAppServiceProviderImpl,
{---------------- End SCGI related-----------------------------}

{----------------Begin uwsgi related-----------------------------}
UwsgiAppServiceProviderImpl,
{---------------- End uwsgi related-----------------------------}

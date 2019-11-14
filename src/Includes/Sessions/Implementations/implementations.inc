{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

(*! ---------------------------------------------
 * implementation units for sessions
 * that is included in fano.pas unit
 *
 * @author Zamrony P. Juhara <zamronypj@yahoo.com>
 *-----------------------------------------------*)

ESessionExpiredImpl,
ESessionInvalidImpl,

DecoratorSessionIdGeneratorImpl,
GuidSessionIdGeneratorImpl,
RawSessionIdGeneratorImpl,
Md5SessionIdGeneratorImpl,
Sha1SessionIdGeneratorImpl,

FileSessionManagerImpl,
CookieSessionManagerImpl,

JsonSessionImpl,
JsonSessionFactoryImpl,

JsonFileSessionManagerFactoryImpl,

IniSessionImpl,
IniSessionFactoryImpl,

IniFileSessionManagerFactoryImpl,

CookieSessionImpl,
CookieSessionFactoryImpl,

CookieSessionManagerFactoryImpl,

SessionMiddlewareExecutorImpl,

SessionResponseImpl,

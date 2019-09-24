{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

(*! ---------------------------------------------
 * alias for implementation in security
 * that is included in implementations.aliases.inc
 *
 * @author Zamrony P. Juhara <zamronypj@yahoo.com>
 *-----------------------------------------------*)

ESessionExpired = ESessionExpiredImpl.ESessionExpired;
ESessionInvalid = ESessionInvalidImpl.ESessionInvalid;

TDecoratorSessionIdGenerator = DecoratorSessionIdGeneratorImpl.TDecoratorSessionIdGenerator;
TGuidSessionIdGenerator = GuidSessionIdGeneratorImpl.TGuidSessionIdGenerator;
TRawSessionIdGenerator = RawSessionIdGeneratorImpl.TRawSessionIdGenerator;
TMd5SessionIdGenerator = Md5SessionIdGeneratorImpl.TMd5SessionIdGenerator;
TSha1SessionIdGenerator = Sha1SessionIdGeneratorImpl.TSha1SessionIdGenerator;

TFileSessionManager = FileSessionManagerImpl.TFileSessionManager;
TJsonSession = JsonSessionImpl.TJsonSession;
TJsonFileSessionManagerFactory = JsonFileSessionManagerFactoryImpl.TJsonFileSessionManagerFactory;

TSessionMiddlewareChainFactory = SessionMiddlewareChainFactoryImpl.TSessionMiddlewareChainFactory;
TSessionMiddlewareChain = SessionMiddlewareChainImpl.TSessionMiddlewareChain;

TSessionResponse = SessionResponseImpl.TSessionResponse;

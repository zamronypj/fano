{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2021 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

{------------ Begin TLHTTPServer-related------------------}
{$IFDEF USE_LNET}
TLnetAppServiceProvider = LnetAppServiceProviderImpl.TLnetAppServiceProvider;
TLnetStdOutWriter = LnetStdOutWriterImpl.TLnetStdOutWriter;
TLnetProcessor = LnetProcessorImpl.TLnetProcessor;
{$ENDIF}
{------------ End TLHttpServer-related------------------}

{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

TOutputBufferFactory = OutputBufferFactoryImpl.TOutputBufferFactory;
TStdErrBufferFactory = StdErrBufferFactoryImpl.TStdErrBufferFactory;

TStringFileReader = StringFileReaderImpl.TStringFileReader;
TStringFileReaderFactory = StringFileReaderFactoryImpl.TStringFileReaderFactory;

TStreamAdapter = StreamAdapterImpl.TStreamAdapter;
EInvalidStream = EInvalidStreamImpl.EInvalidStream;

TStdInReader = StdInReaderImpl.TStdInReader;
TSimpleStdInReader = SimpleStdInReaderImpl.TSimpleStdInReader;

TKeyValuePair = KeyValuePairImpl.TKeyValuePair;
TKeyValuePairFactory = KeyValuePairFactoryImpl.TKeyValuePairFactory;

{$INCLUDE Socket/libs.aliases.inc}
{$INCLUDE Logger/libs.aliases.inc}
{$INCLUDE LibCurl/libs.aliases.inc}
{$INCLUDE FastCGI/libs.aliases.inc}
{$INCLUDE SCGI/libs.aliases.inc}

{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

(*! ---------------------------------------------
 * implementation units for Libs
 * that is included in fano.pas unit
 *
 * @author Zamrony P. Juhara <zamronypj@yahoo.com>
 *-----------------------------------------------*)

OutputBufferFactoryImpl,
StdErrBufferFactoryImpl,

StringFileReaderImpl,
StringFileReaderFactoryImpl,
BasicFileReaderImpl,
BasicFileReaderFactoryImpl,

StreamAdapterImpl,
SerializeableStreamImpl,
EInvalidStreamImpl,

StdInReaderImpl,
SimpleStdInReaderImpl,
StdInFromStringImpl,
StdInFromStreamImpl,

KeyValuePairImpl,
KeyValuePairFactoryImpl,

{$INCLUDE Socket/implementations.inc}
{$INCLUDE Logger/implementations.inc}
{$INCLUDE Regex/implementations.inc}
{$INCLUDE LibCurl/implementations.inc}
{$INCLUDE FastCGI/implementations.inc}
{$INCLUDE SCGI/implementations.inc}

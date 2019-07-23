{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit ScgiStdOutWriterImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    StreamAdapterIntf,
    StdOutIntf,
    StreamStdOutImpl;

type

    (*!-----------------------------------------------
     * FastCGI frame processor that parse FastCGI frame
     * and build CGI environment and write response
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TScgiStdOutWriter = class(TStreamStdOut)
    protected

        (*!------------------------------------------------
         * write string to stream and
         *-----------------------------------------------
         * @param stream, stream to write
         * @param str, string to write
         * @param markEnd, if true, add FCGI_END_REQUEST
         * @return current instance
         *-----------------------------------------------*)
        function writeStream(const stream : IStreamAdapter; const str : string) : IStdOut; override;
    end;

implementation

    (*!------------------------------------------------
     * write string to STDOUT stream
     *-----------------------------------------------
     * @param stream, stream to write
     * @param str, string to write
     * @param markEnd, if true, add FCGI_END_REQUEST
     * @return current instance
     *-----------------------------------------------
     * very long string may be splitted into several
     * FCGI_STDOUT records
     *-----------------------------------------------*)
    function TScgiStdOutWriter.writeStream(const stream : IStreamAdapter; const str : string) : IStdOut;
    begin
        stream.writeBuffer(str[1], length(str));
        result:= self;
    end;
end.

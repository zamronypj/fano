{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit MhdStdOutWriterImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    StreamAdapterIntf,
    StdOutIntf,
    StreamStdOutImpl;

type

    (*!-----------------------------------------------
     * IStdOut implementation having capability to write
     * response to libmicrohttpd
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TMhdStdOutWriter = class(TStreamStdOut)
    protected

        (*!------------------------------------------------
         * write string to stream and
         *-----------------------------------------------
         * @param stream, stream to write
         * @param str, string to write
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
     * @return current instance
     *-----------------------------------------------*)
    function TMhdStdOutWriter.writeStream(const stream : IStreamAdapter; const str : string) : IStdOut;
    var response: PMHD_Response;
    begin
        stream.writeBuffer(str[1], length(str));
        response := MHD_create_response_from_buffer(
            strlen(str),
            pointer(str),
            MHD_RESPMEM_PERSISTENT
        );
        ret := MHD_queue_response(connection, MHD_HTTP_OK, response);
        MHD_destroy_response(response);
        result:= self;
    end;
end.

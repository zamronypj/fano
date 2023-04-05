{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2022 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit MoremoreStdOutWriterImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    SysUtils,
    mormot.net.http,
    StreamAdapterIntf,
    StdOutIntf,
    StreamStdOutImpl,
    MoremoreResponseAwareIntf,
    HttpSvrConfigTypes;

type

    (*!-----------------------------------------------
     * IStdOut implementation having capability to write
     * response to THTTPAsyncServer
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TMoremoreStdOutWriter = class(TStreamStdOut, IMoremoreResponseAware)
    private
        fResponse : THttpServerRequestAbstract;

    protected

        (*!------------------------------------------------
         * write string to stream and
         *-----------------------------------------------
         * @param stream, stream to write
         * @param str, string to write
         * @return current instance
         *-----------------------------------------------*)
        function writeStream(const stream : IStreamAdapter; const str : string) : IStdOut; override;
    public
        (*!------------------------------------------------
         * get THTTPAsyncServer response connection
         *-----------------------------------------------
         * @return connection
         *-----------------------------------------------*)
        function getResponse() : THttpServerRequestAbstract;

        (*!------------------------------------------------
         * set THttpServerRequestAbstract response object
         *-----------------------------------------------*)
        procedure setResponse(aresponse: THttpServerRequestAbstract);

        property response: THttpServerRequestAbstract read getResponse write setResponse;
    end;

implementation

uses

    classes,
    MappedMemoryStreamImpl,
    NullMemoryDeallocatorImpl,
    EInvalidRequestImpl;

const

    HEADER_SEPARATOR_STR = LineEnding + LineEnding;
    HEADER_SEPARATOR_LEN = length(HEADER_SEPARATOR_STR);

    function MemoryStreamToString(M: TCustomMemoryStream): string;
    begin
       SetString(Result, PChar(M.Memory), M.Size div SizeOf(Char));
    end;

    (*!------------------------------------------------
     * write string to STDOUT stream
     *-----------------------------------------------
     * @param stream, stream to write
     * @param str, string to write
     * @return current instance
     *-----------------------------------------------*)
    function TMoremoreStdOutWriter.writeStream(const stream : IStreamAdapter; const str : string) : IStdOut;
    var
        separatorPos : integer;
        content : TMappedMemoryStream;
    begin
        // extract header parts and write it
        separatorPos := pos(HEADER_SEPARATOR_STR, str);
        fResponse.OutCustomHeaders := copy(str, 1, separatorPos + 1);

        //we need str without headers
        //this is simply to avoid having to copy response string
        //to another buffer which may quite big
        content := TMappedMemoryStream.create(
            pointer(pointer(str) + separatorPos + HEADER_SEPARATOR_LEN - 1),
            length(str) - separatorPos - HEADER_SEPARATOR_LEN + 1,
            TNullMemoryDeallocator.create()
        );
        try

            fResponse.OutContent := memoryStreamToString(content);
            result:= self;
        finally
            content.free();
        end;
    end;


    (*!------------------------------------------------
     * get THTTPAsyncServer response connection
     *-----------------------------------------------
     * @return connection
     *-----------------------------------------------*)
    function TMoremoreStdOutWriter.getResponse() : THttpServerRequestAbstract;
    begin
        result := fResponse;
    end;

    (*!------------------------------------------------
     * set THttpServerRequestAbstract response object
     *-----------------------------------------------*)
    procedure TMoremoreStdOutWriter.setResponse(aresponse : THttpServerRequestAbstract);
    begin
        fResponse := aresponse;
    end;

end.

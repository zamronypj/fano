{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FcgiNonBlockingParserImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    InjectableObjectImpl,
    FcgiRecordIntf,
    FcgiRecordFactoryIntf,
    FcgiFrameParserIntf,
    StreamAdapterIntf,
    FcgiBaseParserImpl;

type

    (*!-----------------------------------------------
     * FastCGI Parser which support working with non-blocking
     * socket
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiNonBlockingParser = class (TFcgiBaseParser)
    public
        (*!------------------------------------------------
         * read stream and return found record in memory buffer
         *-----------------------------------------------
         * @param bufPtr, memory buffer to store FastCGI record
         * @param bufSize, memory buffer size
         * @return true if stream is exhausted
         *-----------------------------------------------*)
        function readRecord(
            const stream : IStreamAdapter;
            out bufPtr : pointer;
            out bufSize : ptrUint
        ) : boolean; override;

    end;

implementation

uses

    fastcgi;

    (*!------------------------------------------------
     * read stream and return found record in memory buffer
     *-----------------------------------------------
     * @param bufPtr, memory buffer to store FastCGI record
     * @param bufSize, memory buffer size
     * @return true if stream is exhausted
     *-----------------------------------------------*)
    function TFcgiNonBlockingParser.readRecord(
        const stream : IStreamAdapter;
        out bufPtr : pointer;
        out bufSize : ptrUint
    ) : boolean;
    begin
        result:= false;
        bufPtr := nil;
        bufSize := 0;
        result := streamEmpty;
    end;

end.

{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit UwsgiParserImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    StreamAdapterIntf,
    UwsgiParserIntf,
    EnvironmentIntf;

type

    (*!-----------------------------------------------
     * Class which can process uwsgi stream from web server
     *
     * @link https://uwsgi-docs.readthedocs.io/en/latest/Protocol.html
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TUwsgiParser = class(TInterfacedObject, IUwsgiParser)
    private
        fStdIn : IStreamAdapter;
        fEnv : ICGIEnvironment;

        (*!------------------------------------------------
         * parse string and return CGI environment variable
         *-----------------------------------------------*)
        function parseEnv(const stream : IStreamAdapter; const size : integer) : ICGIEnvironment;

        (*!------------------------------------------------
         * parse string and return POST data as stream
         *-----------------------------------------------*)
        procedure readRequestBodyIfAny(
            const stream : IStreamAdapter;
            const stdIn : IStreamAdapter
        );
    public
        constructor create();
        destructor destroy(); override;

        (*!------------------------------------------------
         * parse request stream
         *-----------------------------------------------*)
        function parse(const stream : IStreamAdapter) : boolean;

        (*!------------------------------------------------
         * get StdIn stream for complete request
         *-----------------------------------------------*)
        function getStdIn() : IStreamAdapter;

        (*!------------------------------------------------
         * get StdIn stream for complete request
         *-----------------------------------------------*)
        function getEnv() : ICGIEnvironment;

    end;

implementation

uses

    Classes,
    SysUtils,
    StreamAdapterImpl,
    NullStreamAdapterImpl,
    KeyValueEnvironmentImpl,
    NullEnvironmentImpl,
    UwsgiParamKeyValuePairImpl,
    EInvalidUwsgiHeaderImpl,
    MappedMemoryStreamImpl,
    NullMemoryDeallocatorImpl;

resourcestring

    sInvalidUwsgiHeader = 'Invalid uwsgi header';

type

    uwsgi_packet_header = packed record
        modifier1 : byte;
        datasize : word;
        modifier2 : byte;
    end;

    constructor TUwsgiParser.create();
    begin
        inherited create();
        //initialize with null implementation
        fStdIn := TStreamAdapter.create(TStringStream.create(''));
        fEnv := TNullCGIEnvironment.create();
    end;

    destructor TUwsgiParser.destroy();
    begin
        fStdIn := nil;
        fEnv := nil;
        inherited destroy();
    end;

    function TUwsgiParser.parseEnv(const stream : IStreamAdapter; const size : integer) : ICGIEnvironment;
    var buff : pointer;
    begin
        //we get uwsgi block vars, read total data
        getMem(buff, size);
        try
            stream.readBuffer(buff^, size);
            result := TKeyValueEnvironment.create(
                TUwsgiParamKeyValuePair.create(
                    TStreamAdapter.create(
                        TMappedMemoryStream.create(
                            buff,
                            size,
                            TNullMemoryDeallocator.create()
                        )
                    )
                )
            );
        finally
            freeMem(buff);
        end;
    end;

    procedure TUwsgiParser.readRequestBodyIfAny(
        const stream : IStreamAdapter;
        const stdIn : IStreamAdapter
    );
    const BUFF_SIZE = 4096;
    var bodyRead : integer;
        buff : pointer;
    begin
        getMem(buff, BUFF_SIZE);
        bodyRead := 0;
        try
            repeat
                bodyRead := stream.read(buff^, BUFF_SIZE);
                stdIn.write(buff^, bodyRead);
            until (bodyRead = -1) or (bodyRead < BUFF_SIZE);
        finally
            freeMem(buff);
        end;
    end;

    (*!------------------------------------------------
     * process request stream
     *-----------------------------------------------*)
    function TUwsgiParser.parse(const stream : IStreamAdapter) : boolean;
    const HDR_SIZE = sizeof(uwsgi_packet_header);
    var hdr : uwsgi_packet_header;
        bytesRead : integer;
    begin
        bytesRead := stream.read(hdr, HDR_SIZE);
        if (bytesRead = HDR_SIZE) then
        begin
            if (hdr.modifier1 = 0) and ((hdr.modifier2 = 0)) then
            begin
                //we get uwsgi block vars, read total data
                fEnv := parseEnv(stream, hdr.datasize);
                readRequestBodyIfAny(stream, fStdIn);
            end;
        end else
        begin
            raise EInvalidUwsgiHeader.create(sInvalidUwsgiHeader);
        end;
        result := (bytesRead = HDR_SIZE);
    end;

    (*!------------------------------------------------
     * get StdIn stream for complete request
     *-----------------------------------------------*)
    function TUwsgiParser.getStdIn() : IStreamAdapter;
    begin
        result := fStdIn;
    end;

    (*!------------------------------------------------
     * get environment for complete request
     *-----------------------------------------------*)
    function TUwsgiParser.getEnv() : ICGIEnvironment;
    begin
        result := fEnv;
    end;

end.

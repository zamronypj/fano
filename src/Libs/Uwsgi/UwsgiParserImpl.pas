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
    TUwsgiParser = class(TInterfacedObject, IScgiParser)
    private
        fStdIn : IStreamAdapter;
        fEnv : ICGIEnvironment;

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
    ScgiParamKeyValuePairImpl,
    EInvalidScgiHeaderImpl,
    EInvalidScgiBodyImpl;

resourcestring

    sInvalidHeaderContent = 'Invalid header content length. Expected %d bytes got %d bytes';
    sInvalidHeaderLen = 'Invalid header length. Expected integer got string ''%s''';
    sInvalidHeaderFormat = 'Invalid header format. Expected end with ''%s'' got ''%s''';
    sInvalidBodyLength = 'Invalid body length. Expected %d bytes got %d bytes';

    constructor TUwsgiParser.create();
    begin
        inherited create();
        //initialize with null implementation
        fStdIn := TNullStreamAdapter.create();
        fEnv := TNullCGIEnvironment.create();
    end;

    destructor TUwsgiParser.destroy();
    begin
        inherited destroy();
        fStdIn := nil;
        fEnv := nil;
    end;

    (*!------------------------------------------------
     * process request stream
     *-----------------------------------------------*)
    function TUwsgiParser.parse(const stream : IStreamAdapter) : boolean;
    var streamEmpty : boolean;
        ch : char;
        bytesRead : integer;
        lenStr : string;
    begin
        lenStr := '';
        streamEmpty := false;
        repeat
            bytesRead := stream.read(ch, 1);
            if (bytesRead > 0) then
            begin
                streamEmpty := parseNetString(ch, lenStr, stream);
            end else
            begin
                streamEmpty := true;
            end;
        until streamEmpty;
        result := streamEmpty;
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

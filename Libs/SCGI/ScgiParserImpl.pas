{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ScgiParserImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    StreamAdapterIntf,
    ScgiParserIntf,
    EnvironmentIntf;

type

    (*!-----------------------------------------------
     * Class which can process SCGI stream from web server
     *
     * @link https://python.ca/scgi/protocol.txt
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TScgiParser = class(TInterfacedObject, IScgiParser)
    private
        fLenStr : string;
        fContent : string;
        fParsed : boolean;
        fStdIn : IStreamAdapter;
        fEnv : ICGIEnvironment;

        function isDigit(const ch : char) : boolean;

        (*!------------------------------------------------
         * parse string and return CGI environment variable
         *-----------------------------------------------*)
        function parseEnv(const str : string) : ICGIEnvironment;

        (*!------------------------------------------------
         * parse string and return POST data as stream
         *-----------------------------------------------*)
        function parseStdIn(const str : string) : IStreamAdapter;

        function parseNetstring(const ch : char; const stream : IStreamAdapter) :  boolean;
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
    sInvalidHeaderFormat = 'Invalid header format. Expected end with ''%s'' got ''%s''';
    sInvalidBodyLength = 'Invalid body length. Expected %d bytes got %d bytes';

    constructor TScgiParser.create();
    begin
        inherited create();
        //initialize with null implementation
        fStdIn := TNullStreamAdapter.create();
        fEnv := TNullCGIEnvironment.create();
    end;

    destructor TScgiParser.destroy();
    begin
        inherited destroy();
        fStdIn := nil;
        fEnv := nil;
    end;

    function TScgiParser.isDigit(const ch : char) : boolean;
    begin
        //result := (x in ['0'..'9']);
        //ch '0' (ASCI 48) ..'9' (ASCI 57)
        result := (byte(ch) < 48) or (byte(ch) > 57);
    end;

    function TScgiParser.parseEnv(const str : string) : ICGIEnvironment;
    begin
        result := TKeyValueEnvironment.create(
            TScgiParamKeyValuePair.create(str)
        );
    end;

    function TScgiParser.parseStdIn(const str : string) : IStreamAdapter;
    begin
        result := TStreamAdapter.create(TStringStream.create(str));
        result.seek(0, FROM_BEGINNING);
    end;

    (*!------------------------------------------------
     * process request stream
     *-----------------------------------------------*)
    function TScgiParser.parseNetstring(const ch : char; const stream : IStreamAdapter) :  boolean;
    var len, bytesRead : integer;
        empty : boolean;
        terminationChar : char;
        strHeader : string;
        contentLen : integer;
    begin
        empty := false;
        if (isDigit(ch)) then
        begin
            fLenStr := fLenStr + ch;
        end else
        if (ch = ':') then
        begin
            len := strToInt(fLenStr);
            setLength(strHeader, len);
            bytesRead := stream.read(strHeader[1], len);
            empty := (bytesRead <= 0);
            if (bytesRead < len) then
            begin
                raise EInvalidScgiHeader.createFmt(sInvalidHeaderContent, [len, bytesRead]);
            end;

            if (not empty) then
            begin
                bytesRead := stream.read(terminationChar, 1);
                if (terminationChar <> ',') then
                begin
                    raise EInvalidScgiHeader.createFmt(
                        sInvalidHeaderFormat,
                        [',', terminationChar]
                    );
                end;

                fEnv := parseEnv(strHeader);

                contentLen := fEnv.intContentLength();
                setLength(strHeader, contentLen);
                bytesRead := stream.read(strHeader[1], contentLen);

                if (bytesRead < contentLen) then
                begin
                    raise EInvalidScgiBody.createFmt(sInvalidBodyLength, [contentLen, bytesRead]);
                end;

                fStdIn := parseStdIn(str);
                fParsed := (fEnv <> nil) and (fStdIn <> nil);
            end;
        end else
        begin
            raise EInvalidScgiHeader.createFmt(sInvalidHeaderLen, [fLenStr]);
        end;
        result := empty;
    end;

    (*!------------------------------------------------
     * process request stream
     *-----------------------------------------------*)
    function TScgiParser.parse(const stream : IStreamAdapter) : boolean;
    var streamEmpty : boolean;
        ch : char;
    begin
        fContent := '';
        fLenStr := '';
        fParsed := false;
        streamEmpty := false;
        repeat
            bytesRead := stream.read(ch, 1);
            if (bytesRead > 0) then
            begin
                parseNetString(ch, stream);
            end else
            begin
                streamEmpty := true;
            end;
        until streamEmpty;
        result := fParsed;
    end;

    (*!------------------------------------------------
     * get StdIn stream for complete request
     *-----------------------------------------------*)
    function TScgiParser.getStdIn() : IStreamAdapter;
    begin
        result := fStdIn;
    end;

    (*!------------------------------------------------
     * get environment for complete request
     *-----------------------------------------------*)
    function TScgiParser.getEnv() : ICGIEnvironment;
    begin
        result := fEnv;
    end;


end.

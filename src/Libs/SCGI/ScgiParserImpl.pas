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

        function parseNetstring(const ch : char; var lenStr : string; const stream : IStreamAdapter) :  boolean;
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

        (*!------------------------------------------------
        * get number of bytes of complete request based
        * on information buffer
        *-----------------------------------------------
        * @return number of bytes of complete request
        *-----------------------------------------------*)
        function expectedSize(const buff : IStreamAdapter) : int64;
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
    EInvalidScgiBodyImpl,
    RegexIntf,
    RegexImpl;

resourcestring

    sInvalidHeaderContent = 'Invalid header content length. Expected %d bytes got %d bytes';
    sInvalidHeaderLen = 'Invalid header length. Expected integer got string ''%s''';
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
        result := (byte(ch) >= 48) and (byte(ch) <= 57);
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
    function TScgiParser.parseNetstring(
        const ch : char;
        var lenStr : string;
        const stream : IStreamAdapter
    ) :  boolean;
    var len, bytesRead : integer;
        empty : boolean;
        terminationChar : char;
        strHeader : string;
        contentLen : integer;
    begin
        empty := false;
        if (isDigit(ch)) then
        begin
            lenStr := lenStr + ch;
        end else
        if (ch = ':') then
        begin
            len := strToInt(lenStr);
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
                if (contentLen > 0) then
                begin
                    //read body
                    setLength(strHeader, contentLen);
                    bytesRead := stream.read(strHeader[1], contentLen);

                    if (bytesRead < contentLen) then
                    begin
                        raise EInvalidScgiBody.createFmt(sInvalidBodyLength, [contentLen, bytesRead]);
                    end;

                    fStdIn := parseStdIn(strHeader);
                end;
                empty := true;
            end;
        end else
        begin
            raise EInvalidScgiHeader.createFmt(sInvalidHeaderLen, [ lenStr ]);
        end;
        result := empty;
    end;

    (*!------------------------------------------------
     * process request stream
     *-----------------------------------------------*)
    function TScgiParser.parse(const stream : IStreamAdapter) : boolean;
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

    (*!------------------------------------------------
     * get total expected data in bytes in buffer
     *-----------------------------------------------
     * @return number of bytes
     *-----------------------------------------------*)
    function TScgiParser.expectedSize(const buff : IStreamAdapter) : int64;
    var str : string;
        regex : TRegex;
        res : TRegexMatchResult;
    begin
        result := -1;
        if buff.size() > 0 then
        begin
            setLength(str, buff.size());
            buff.seek(0, FROM_BEGINNING);
            buff.read(str[1], length(str));
            regex := TRegex.create();
            try
                res := regex.match('^(\d+)\:.*CONTENT_LENGTH\x00(\d+)\x00', str);
                if (res.matched) then
                begin
                    //total bytes of SCGI request is
                    //length of env vars + one termination char (coma) + content length of body
                    result := strToInt(res[0][1]) + strToInt(res[0][2]) + 1;
                end;
            finally
                regex.free();
            end;
        end;
    end;

end.

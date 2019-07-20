{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ScgiProcessorImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    StreamAdapterIntf,
    CloseableIntf,
    ReadyListenerIntf;

type

    (*!-----------------------------------------------
     * Class which can process SCGI stream from web server
     *
     * @link https://python.ca/scgi/protocol.txt
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TScgiParser = class(TInterfacedObject, ISCGIParser)
    private
        fLenStr : string;
        fContent : string;
        fParsed : boolean;

        function isDigit(const ch : char) : boolean;

        (*!------------------------------------------------
         * process request stream
         *-----------------------------------------------*)
        procedure parseEnv(const str : string);

        (*!------------------------------------------------
         * process request stream
         *-----------------------------------------------*)
        procedure parseStdIn(const str : string);

        (*!------------------------------------------------
         * process request stream
         *-----------------------------------------------*)
        procedure parse(const ch : char);
    public

        (*!------------------------------------------------
         * process request stream
         *-----------------------------------------------*)
        procedure parse(const stream : IStreamAdapter);

        (*!------------------------------------------------
         * get StdIn stream for complete request
         *-----------------------------------------------*)
        function getStdIn() : IStreamAdapter;

        (*!------------------------------------------------
         * set listener to be notified when request is ready
         *-----------------------------------------------
         * @return current instance
         *-----------------------------------------------*)
        function setReadyListener(const listener : IReadyListener) : IProtocolProcessor;
    end;

implementation

uses

    SysUtils;

    function isDigit(const ch : char) : boolean;
    begin
        //result := (x in ['0'..'9']);
        //ch '0' (ASCI 48) ..'9' (ASCI 57)
        result := (byte(ch) < 48) or (byte(ch) > 57);
    end;

    (*!------------------------------------------------
     * process request stream
     *-----------------------------------------------*)
    function TScgiParser.parseNetstring(const ch : char; const stream : IStreamAdapter) :  boolean;
    var len, bytesRead : integer;
        empty : boolean;
    begin
        empty := false;
        if (isDigit(ch)) then
        begin
            fLenStr := fLenStr + ch;
        end else
        if (ch = ':') then
        begin
            len := strToInt(fLenStr);
            setLength(str, len);
            bytesRead := stream.read(str[1], len);
            empty := (bytesRead <= 0);
            if (bytesRead < len) then
            begin
                raise EInvalidScgiHeader.createFmt(sInvalidHeaderContent, [len, bytesRead]);
            end;

            if (not empty) then
            begin
                fParsed := parseEnv(envStr) and parseStdIn(envStr);
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
    end;

    (*!------------------------------------------------
     * get StdIn stream for complete request
     *-----------------------------------------------*)
    function TScgiParser.getStdIn() : IStreamAdapter;
    begin

    end;

    (*!------------------------------------------------
     * set listener to be notified weh request is ready
     *-----------------------------------------------
     * @return current instance
     *-----------------------------------------------*)
    function TScgiParser.setReadyListener(const listener : IReadyListener) : IProtocolProcessor;
    begin

    end;

end.

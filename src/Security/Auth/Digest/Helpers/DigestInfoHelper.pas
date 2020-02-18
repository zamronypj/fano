{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit DigestInfoHelper;

interface

{$MODE OBJFPC}
{$H+}

uses

    DigestInfoTypes;

    function initEmptyDigestInfo(const requestMethod : string) : TDigestInfo;

    function fillDigestInfo(
        const di : TDigestInfo;
        const key: string;
        const value : string
    ) : TDigestInfo;

    function getDigestInfo(
        const requestMethod : string;
        const authHeaderLine : string
    ) : TDigestInfo;

implementation

uses

    regexpr;

    function initEmptyDigestInfo(const requestMethod : string) : TDigestInfo;
    begin
        with result do
        begin
            username := '';
            nonce := '';
            realm := '';
            uri := '';
            qop := '';
            nc := '';
            cnonce := '';
            response := '';
            opaque := '';
            method := requestMethod;
        end;
    end;

    function fillDigestInfo(
        const di : TDigestInfo;
        const key: string;
        const value : string
    ) : TDigestInfo;
    begin
        with di do
        begin
            case key of
                'username' : username := value;
                'nonce' : nonce := value;
                'realm' : realm := value;
                'uri' : uri := value;
                'qop' : qop := value;
                'nc' : nc := value;
                'cnonce' : cnonce := value;
                'response' : response := value;
                'opaque' : opaque := value;
            end;
        end;
        result := di;
    end;

    (*!------------------------------------------------
     * extract value from Authorization: Digest ...
     *-------------------------------------------------
     * @param requestMethod current request method
     * @param authHeaderLine content of Authorization request header
     * @return parsed value
     *-------------------------------------------------
     *
     *   GET /dir/index.html HTTP/1.0
     *   Host: localhost
     *   Authorization: Digest username="Mufasa",
     *                       realm="testrealm@host.com",
     *                       nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093",
     *                       uri="/dir/index.html",
     *                       qop=auth,
     *                       nc=00000001,
     *                      cnonce="0a4f113b",
     *                       response="6629fae49393a05397450978507c4ef1",
     *                       opaque="5ccc069c403ebaf9f0171e9517f40e41"
     *
     * Parse content of Authorization request header above into TDigestInfo
     * digestInfo.username='Mufasa'
     * digestInfo.realm='testrealm@host.com'
     * digestInfo.nonce='dcd98b7102dd2f0e8b11d0f600bfb0c093'
     *-------------------------------------------------*)
    function getDigestInfo(
        const requestMethod : string;
        const authHeaderLine : string
    ) : TDigestInfo;
    const REGEXPATTERN = '(\w+)[\s]*=[\s]*(([^"''\s]+)|''([^'']*)''|"([^"]*)")\s*,*';
    var re : TRegExpr;
        key, value : string;
    begin
        result := initEmptyDigestInfo(requestMethod);
        re := TRegExpr.create(REGEXPATTERN);
        try
            re.modifierG := true;
            re.modifierM := true;
            setLength(result.matches, 0);
            if re.exec(authHeaderLine) then
            begin
                extractKeyValuePair(re, key, value);
                result := fillDigestInfo(result, key, value);
                while (re.execNext()) do
                begin
                    extractKeyValuePair(re, key, value);
                    result := fillDigestInfo(result, key, value);
                end;
            end;
        finally
            re.free();
        end;
    end;


end.

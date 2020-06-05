{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2020 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit UrlHelpersImpl;

interface

{$MODE OBJFPC}
{$MODESWITCH TYPEHELPERS}
{$H+}

uses

    sysutils;

type

    (*!------------------------------------------------
     * Type helper for url string
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TUrlHelper = type helper(TStringHelper) for string
    public

        (*!------------------------------------------------
         * url encode
         *-------------------------------------------------
         * @author Zamrony P. Juhara <zamronypj@yahoo.com>
         * @author BenJones
         * @credit http://forum.lazarus.freepascal.org/index.php?topic=15088.0
         *-----------------------------------------------*)
        function urlEncode() : string;

        (*!------------------------------------------------
         * url decode
         *-------------------------------------------------
         * @author Zamrony P. Juhara <zamronypj@yahoo.com>
         * @author BenJones
         * @credit http://forum.lazarus.freepascal.org/index.php?topic=15088.0
         *-----------------------------------------------*)
        function urlDecode() : string;

        (*!------------------------------------------------
         * remove query string part from URL
         *-------------------------------------------------
         * @return url without query string
         *-----------------------------------------------
         * Example:
         * url := 'http://fanoframework.github.io?id=1'
         * strippedUrl := url.stripQueryString();
         *
         * strippedUrl will contains
         * 'http://fanoframework.github.io'
         *-----------------------------------------------*)
        function stripQueryString() : string;
    end;

implementation

uses

    httpprotocol;

    (*!------------------------------------------------
     * url encode
     *-----------------------------------------------*)
    function TUrlHelper.urlEncode() : string;
    begin
        result := httpEncode(self);
    end;

    (*!------------------------------------------------
     * url decode
     *-------------------------------------------------
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     * @author BenJones
     * @credit http://forum.lazarus.freepascal.org/index.php?topic=15088.0
     *-----------------------------------------------*)
    function TUrlHelper.urlDecode() : string;
    begin
        result := httpDecode(self);
    end;


    (*!------------------------------------------------
     * remove query string part from URL
     *-------------------------------------------------
     * @return url without query string
     *-----------------------------------------------
     * Example:
     * url := 'http://abc.io?id=1'
     * strippedUrl := url.stripQueryString();
     *
     * strippedUrl will contains
     * 'http://abc.io'
     *-----------------------------------------------*)
    function TUrlHelper.stripQueryString() : string;
    var queryStrPos : integer;
    begin
        queryStrPos := pos('?', self);
        if (queryStrPos = 0) then
        begin
            //no query string
            result := self;
        end else
        begin
            result := system.copy(self, 1, queryStrPos - 1);
        end;
    end;

end.

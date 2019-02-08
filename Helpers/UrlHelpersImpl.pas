{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
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

    (*!------------------------------------------------
     * url encode
     *-------------------------------------------------
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     * @author BenJones
     * @credit http://forum.lazarus.freepascal.org/index.php?topic=15088.0
     *-----------------------------------------------*)
    function TUrlHelper.urlEncode() : string;
    const safeMask = ['A'..'Z', '0'..'9', 'a'..'z', '*', '@', '.', '_', '-'];
    var x, len : integer;
    begin
        //Init
        result := '';
        len := self.length;
        for x := 1 to len do
        begin
            //Check if we have a safe char
            if (self[x] in safeMask) then
            begin
                //Append all other chars
                result := result + self[x];
            end else
            if (self[x] = ' ') then
            begin
                //Append space
                result := result + '+';
            end else
            begin
                //Convert to hex
                result := result + '%' + (ord(self[x])).tohexString(2);
            end;
        end;
    end;

    (*!------------------------------------------------
     * url decode
     *-------------------------------------------------
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     * @author BenJones
     * @credit http://forum.lazarus.freepascal.org/index.php?topic=15088.0
     *-----------------------------------------------*)
    function TUrlHelper.urlDecode() : string;
    var x, len: integer;
        ch: char;
        sVal: string;
    begin
        //Init
        result := '';
        x := 1;
        len := self.length;
        while x <= len do
        begin
            //Get single char
            ch := self[x];

            if (ch = '+') then
            begin
                //Append space
                result := result + ' ';
            end else
            if (ch <> '%') then
            begin
                //Append other chars
                result := result + ch;
            end else
            begin
                //Get value
                sVal := '$' + self.substring(x, 2);
                //Convert sval to int then to char
                result := result + char(sVal.toInteger());
                //Inc counter by 2
                inc(x, 2);
            end;
            //Inc counter
            inc(x);
        end;
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

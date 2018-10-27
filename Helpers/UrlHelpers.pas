{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit UrlHelpers;

interface

{$MODE OBJFPC}
{$MODESWITCH TYPEHELPERS}
{$H+}

uses

    sysutils;

type

    (*!------------------------------------------------
     * Type helper for url encode/decode
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     * @author BenJones
     * @credit http://forum.lazarus.freepascal.org/index.php?topic=15088.0
     *-----------------------------------------------*)
    TUrlHelper = type helper(TStringHelper) for string
        function urlEncode() : string;
        function urlDecode() : string;
    end;

implementation

    function TUrlHelper.urlEncode() : string;
    const safeMask = ['A'..'Z', '0'..'9', 'a'..'z', '*', '@', '.', '_', '-'];
    var x, len : integer;
    begin
        //Init
        result := '';
        len := length(self);
        for x := 1 to len do
        begin
            //Check if we have a safe char
            if (self[x] in safeMask) then
            begin
                //Append all other chars
                result := result + url[x];
            end else
            if (self[x] = ' ') then
            begin
                //Append space
                result := result + '+';
            end else
            begin
                //Convert to hex
                result := result + '%' + intToHex(ord(self[x]), 2);
            end;
        end;
    end;

    function TUrlHelper.urlDecode() : string;
    var x, len: integer;
        ch: char;
        sVal: string;
    begin
        //Init
        result := '';
        x := 1;
        len := length(self);
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
                sVal := copy(self, x + 1, 2);
                //Convert sval to int then to char
                result := result + char(strToInt('$' + sVal));
                //Inc counter by 2
                inc(x, 2);
            end;
            //Inc counter
            inc(x);
        end;
    end;

end.
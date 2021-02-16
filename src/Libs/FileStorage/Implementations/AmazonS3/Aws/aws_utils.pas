{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2021 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit aws_utils;

interface

{$MODE OBJFPC}
{$H+}

type

    TUrlEncodeChars = set of ansichar;

    (*!------------------------------------------------
     * encode chars as url encoded char
     *-------------------------------------------------
     * for example ':' (ASCII 034h) will be translated to '%3A'
     *-------------------------------------------------
     * @param input input string
     * @param charsToEncode set of chars to encode
     * @return string with special chars url encoded
     *--------------------------------------------------*)
    function urlEncodeChars(const input : string; charsToEncode : TUrlEncodeChars) : string;


implementation

    (*!------------------------------------------------
     * encode chars as url encoded char
     *-------------------------------------------------
     * for example ':' (ASCII 034h) will be translated to '%3A'
     *-------------------------------------------------
     * @param input input string
     * @param charsToEncode set of chars to encode
     * @return string with special chars url encoded
     *--------------------------------------------------*)
    function urlEncodeChars(const input : string; charsToEncode : TUrlEncodeChars) : string;
    var inputCh : ansichar;
        i, outputLen, actualLen : integer;
        encodedChar : string;
    begin
        actualLen = length(input);

        //allocate enough string with assumption
        //worst case is that all chars in input is in charsToEncode so output string
        //will be 3 * original input length. For example '::' become '%3A%3A'
        setLength(result, actualLen * 3);
        outputLen := 0;
        for i := 1 to actualLen do
        begin
            inputCh := input[i];
            if inputCh in charsToEncode then
            begin
                encodedChar := IntToHex(ord(inputCh), 2);
                result[i] := '%';
                result[i+1] := encodedChar[1];
                result[i+2] := encodedChar[2];
                inc(outputLen, 3);
            end else
            begin
                result[i] := inputCh;
                inc(outputLen);
            end;
        end;
        setLength(result, outputLen);
    end;

end.

{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ScgiParamKeyValuePairImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    StreamAdapterIntf,
    KeyValuePairImpl;

type
    (*!------------------------------------------------
     * key value pair class having capability
     * to retrieve SCGI environment variable
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *--------------------------------------------------*)
    TScgiParamKeyValuePair = class(TKeyValuePair)
    private
        procedure readKeyValueFromString(const aStr : string);
    public
        constructor create(const paramStr : string);
    end;

implementation

uses

    StrUtils;

    constructor TScgiParamKeyValuePair.create(const paramStr : string);
    begin
        inherited create();
        readKeyValueFromString(paramStr);
    end;

    procedure TScgiParamKeyValuePair.readKeyValueFromString(const aStr : string);
    var separator0, separator1 : integer;
        akey, avalue : string;
        tmpStr : string;
    begin
        //environment variable will be pass in aStr as
        //key#0value#0key#0value#0key#0value#0 ....
        tmpStr := aStr;
        while (length(tmpStr) > 0) do
        begin
            separator0 := pos(#0, tmpStr);
            separator1 := posEx(#0, tmpStr, separator0 + 1);
            akey := copy(tmpStr, 1, separator0 - 1);
            avalue := copy(tmpStr, separator0 + 1, separator1 - separator0 - 1);
            delete(tmpStr, 1, separator1);
            setValue(akey, avalue);
        end;
    end;

end.

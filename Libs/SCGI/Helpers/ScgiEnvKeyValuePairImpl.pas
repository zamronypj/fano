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
    public
        constructor create(const paramStr : string);
    end;

implementation

    constructor TScgiParamKeyValuePair.create(const paramStr : IStreamAdapter);
    begin
        inherited create();
        readKeyValueFromString(paramStr);
    end;

    procedure TScgiParamKeyValuePair.readKeyValueFromString(const aStr : string);
    var separator0, separator1 : integer;
        akey, avalue : string;
        tmpStr : string;
    begin
        tmpStr := astr;
        while (length(tmpStr) > 0) do
        begin
            separator0 := pos(#0, tmpStr);
            separator1 := posEx(#0, tmpStr, separator0 + 1);
            akey := copy(tmpStr, 1, separator0);
            avalue := copy(tmpStr, separator0 + 1, separator1);
            tmpStr := delete(tmpStr, 1, separator1);
            setValue(akey, avalue);
        end;
    end;

end.

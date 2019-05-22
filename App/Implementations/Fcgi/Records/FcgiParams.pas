{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit FcgiParams;

interface

{$MODE OBJFPC}
{$H+}

type

    (*!-----------------------------------------------
     * Params record (FCGI_PARAMS)
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiParams = class(TFcgiRecord)
    private
        keyValues : IKeyValuePair;
    public
        constructor create(
            const requestId : word;
            const aKeyValues : IKeyValuePair
        );

        (*!------------------------------------------------
        * write record data to stream
        *-----------------------------------------------
        * @param stream, stream instance where to write
        * @return number of bytes actually written
        *-----------------------------------------------*)
        function write(const stream : IStreamAdapter) : integer; override;
    end;

implementation

uses

    fastcgi;

    constructor TFcgiParams.create(
        const requestId : word;
        const aKeyValues : IKeyValuePair
    );
    begin
        inherited create(FCGI_PARAMS, requestId);
        keyValues := aKeyValues;
    end;

    (*!------------------------------------------------
    * write record data to stream
    *-----------------------------------------------
    * @param stream, stream instance where to write
    * @return number of bytes actually written
    *-----------------------------------------------*)
    function TFcgiParams.write(const stream : IStreamAdapter) : integer; override;
    var i, totalKeys : integer;
        akey : shortstring;
        avalue : string;
        lenKey : integer;
        lenValue : integer;
        paramRec : PFCGI_ContentRecord;
    begin
        totalKeys := keyValues.count();
        for i := 0 to totalKeys - 1 do
        begin
            akey := keyValues.getKey(i);
            lenKey := length(akey);
            avalue := keyValues.getValue(akey);
            lenValue := length(avalue);
            if (lenKey > 127) then
            begin
            end else
            begin
            end;

            if (lenValue > 127) then
            begin
            end else
            begin
            end;
        end;
    end;
end.

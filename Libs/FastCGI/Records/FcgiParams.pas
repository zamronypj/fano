{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FcgiParams;

interface

{$MODE OBJFPC}
{$H+}

uses

    KeyValuePairIntf,
    StreamAdapterIntf,
    FcgiRecord;

type

    (*!-----------------------------------------------
     * Params record (FCGI_PARAMS)
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiParams = class(TFcgiRecord, IKeyValuePair)
    private
        fKeyValues : IKeyValuePair;
    public
        (*!------------------------------------------------
         * constructor
         *-----------------------------------------------
         * @param requestId, id of request
         * @return aKeyValues, instance IKeyValuePair which will store key value
         *-----------------------------------------------*)
        constructor create(const requestId : word; const aKeyValues : IKeyValuePair);

        (*!------------------------------------------------
         * destructor
         *-----------------------------------------------*)
        destructor destroy(); override;

        (*!------------------------------------------------
        * write record data to stream
        *-----------------------------------------------
        * @param stream, stream instance where to write
        * @return number of bytes actually written
        *-----------------------------------------------*)
        function write(const stream : IStreamAdapter) : integer; override;

        property keyValues : IKeyValuePair read fKeyValues implements IKeyValuePair;
    end;

implementation

uses

    fastcgi;

    (*!------------------------------------------------
     * constructor
     *-----------------------------------------------
     * @param requestId, id of request
     * @return aKeyValues, instance IKeyValuePair which will store key value
     *-----------------------------------------------*)
    constructor TFcgiParams.create(
        const requestId : word;
        const aKeyValues : IKeyValuePair
    );
    begin
        inherited create(FCGI_PARAMS, requestId);
        fKeyValues := aKeyValues;
    end;

    (*!------------------------------------------------
     * destructor
     *-----------------------------------------------*)
    destructor TFcgiParams.destroy();
    begin
        inherited destroy();
        fKeyValues := nil;
    end;

    (*!------------------------------------------------
    * write record data to stream
    *-----------------------------------------------
    * @param stream, stream instance where to write
    * @return number of bytes actually written
    *-----------------------------------------------*)
    function TFcgiParams.write(const stream : IStreamAdapter) : integer;
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

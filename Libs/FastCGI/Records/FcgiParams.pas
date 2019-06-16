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
        constructor create(
            const stream : IStreamAdapter;
            const requestId : word;
            const aKeyValues : IKeyValuePair
        );

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

    fastcgi,
    classes;

    (*!------------------------------------------------
     * constructor
     *-----------------------------------------------
     * @param requestId, id of request
     * @return aKeyValues, instance IKeyValuePair which will store key value
     *-----------------------------------------------*)
    constructor TFcgiParams.create(
        const stream : IStreamAdapter;
        const requestId : word;
        const aKeyValues : IKeyValuePair
    );
    begin
        inherited create(stream, FCGI_PARAMS, requestId);
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
    * calculate numuber of bytes to write per record
    *-----------------------------------------------
    * @param len, current data length
    * @param excess, current data length excess
    * @return number of bytes actually written
    *-----------------------------------------------*)
    function TFcgiParams.getPaddingToWrite(const len: word) : byte;
    const MAX_LENGTH = $EFFF;
    begin
        if ((len mod FCGI_HEADER_LEN) = 0) then
        begin
            result := 0;
        end else
        begin
            result := FCGI_HEADER_LEN - (len mod FCGI_HEADER_LEN);
        end;
    end;

    (*!------------------------------------------------
    * write record data to stream
    *-----------------------------------------------
    * @param stream, stream instance where to write
    * @return number of bytes actually written
    *-----------------------------------------------*)
    function TFcgiParams.writeRecord(const stream : IStreamAdapter; const data : pointer; const size:integer) : integer;
    const zeroByte = 0;
    var headerRec : FCGI_Header;
    begin
        fContentLength := size;
        fPaddingLength := getPaddingToWrite(fContentLength);
        fillChar(headerRec, sizeof(FCGI_Header), zeroByte);
        headerRec.version := fVersion;
        headerRec.reqtype := fType;
        headerRec.paddingLength := fPaddingLength;
        headerRec.contentLength := NtoBE(fContentLength);
        headerRec.requestId := NToBE(fRequestID);
        stream.writeBuffer(headerRec, sizeof(FCGI_Header));
        stream.writeBuffer(data, size);
        stream.writeBuffer(zeroByte, fPaddingLength);
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
        tmp : TMemoryStream;
    begin
        tmp := TMemoryStream.create();
        try
            totalKeys := keyValues.count();
            for i := 0 to totalKeys - 1 do
            begin
                akey := keyValues.getKey(i);
                lenKey := length(akey);
                avalue := keyValues.getValue(akey);
                lenValue := length(avalue);
                if (lenKey > 127) then
                begin
                    //encode length as four byte data
                    //with high-order bit = 1 to mark 4 bytes encoding
                    lenKey := lenKey or $80000000;
                    tmp.writeBuffer(lenKey, 4);
                end else
                begin
                    //encode length as one byte data
                    tmp.writeBuffer(lenKey, 1);
                end;

                if (lenValue > 127) then
                begin
                    //encode length as four byte data
                    //with high-order bit = 1 to mark 4 bytes encoding
                    lenValue := lenValue or $80000000;
                    tmp.writeBuffer(lenValue, 4);
                end else
                begin
                    //encode length as four byte data
                    tmp.writeBuffer(lenValue, 4);
                end;

                tmp.writeBuffer(akey[1], length(akey));
                tmp.writeBuffer(avalue[1], length(avalue));
            end;

            writeRecord(stream, tmp.memory, tmp.size);
        finally
            tmp.free();
        end;
    end;
end.

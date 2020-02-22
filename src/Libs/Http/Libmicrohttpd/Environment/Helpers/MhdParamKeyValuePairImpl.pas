{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit MhdParamKeyValuePairImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    libmicrohttpd,
    StreamAdapterIntf,
    KeyValuePairImpl;

type

    TMhdData = record
        //this will be provided by libmicrohttpd
        connection : PMHDConnection;
        url: Pcchar;
        method: Pcchar;
        version: Pcchar;

        //this will be set by application
        documentRoot : string;
        serverAddr : string;
        serverPort : word;
        serverName : string;
        serverSoftware : string;
        serverAdmin : string;
    end;

    (*!------------------------------------------------
     * key value pair class having capability
     * to retrieve CGI environment variable from libmicrohttpd
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *--------------------------------------------------*)
    TMhdParamKeyValuePair = class(TKeyValuePair)
    private
        procedure initEnvVars(const mhdData : TMhdData);
    public
        constructor create(const mhdData : TMhdData);
    end;

implementation

uses

    SysUtils,
    Sockets;

    (*!-----------------------------------
     * internal callback which we use to extract
     * request header
     *------------------------------------
     * @param cls user-defined data that is passed
     *        to MHD_get_connection_values()
     * @param kind type of data we are dealing
     * @param key name of data
     * @param value value of data
     * @return flag if we should continue or stop
     *--------------------------------------*)
    function extractHeaders (
        cls : pointer;
        kind : MHD_ValueKind;
        key : pcchar;
        value : pcchar
    ) : cint; cdecl;
    var keyValueInst : TMhdParamKeyValuePair;
        akey, strKey : string;
    begin
        //cls = self
        keyValueInst := TMhdParamKeyValuePair(cls);
        akey := PChar(key);

        //turn request header into format according to CGI Environment (RFC 3875)
        //'Host' ==> 'HTTP_HOST',
        //'User-Agent' ==> 'HTTP_USER_AGENT' .. etc,
        //except
        //'Content-Length' ==> 'CONTENT_LENGTH'
        //'Content-Type' ==> 'CONTENT_TYPE'
        strKey := uppercase(stringReplace(akey, '-', '_', [rdReplaceAll]));
        if not ((akey = 'Content-Length') or (akey = 'Content-Type')) then
        begin
            strKey := 'HTTP_' + strKey;
        end;
        keyValueInst.setValue(strKey, PChar(value));

        //we will process all data so just return MHD_YES
        result := MHD_YES;
    end;

    (*!-----------------------------------
     * internal callback which we use to extract
     * request query strings
     *------------------------------------
     * @param cls user-defined data that is passed
     *        to MHD_get_connection_values()
     * @param kind type of data we are dealing
     * @param key name of data
     * @param value value of data
     * @return flag if we should continue or stop
     *--------------------------------------*)
    function extractQueryStrs (
        cls : pointer;
        kind : MHD_ValueKind;
        key : pcchar;
        value : pcchar
    ) : cint; cdecl;
    var keyValueInst : TMhdParamKeyValuePair;
        queryStr : string;
    begin
        //cls = self
        keyValueInst := TMhdParamKeyValuePair(cls);

        //TODO: this is little bit not optimized because query string
        //are already parsed by libmicrohttpd. We need to do this
        //so we do not need to change how everything works
        queryStr := keyValueInst.getValue('QUERY_STRING');
        if (queryStr = '') then
        begin
            queryStr := pchar(key) + '=' + pchar(value);
        end else
        begin
            queryStr := '&' + pchar(key) + '=' + pchar(value);
        end;
        keyValueInst.setValue('QUERY_STRING', queryStr);

        //we will process all data so just return MHD_YES
        result := MHD_YES;
    end;

    constructor TMhdParamKeyValuePair.create(const mhdData : TMhdData);
    begin
        inherited create();
        initEnvVars(mhdData);
    end;

    procedure TMhdParamKeyValuePair.initEnvVars(const mhdData : TMhdData);
    var connectionInfo : PMHD_ConnectionInfo;
        ipAddress : string;
    begin
        setValue('GATEWAY_INTERFACE', 'CGI/1.1');
        setValue('SERVER_ADMIN', mhData.serverAdmin);
        setValue('SERVER_NAME', mhData.serverName);
        setValue('SERVER_ADDR', mhData.serverAddr);
        setValue('SERVER_PORT', mhData.serverPort);
        setValue('SERVER_SOFTWARE', mhData.serverSoftware);
        setValue('DOCUMENT_ROOT', mhData.documentRoot);
        setValue('SERVER_PROTOCOL', PCHAR(mhData.version));

        setValue('REQUEST_METHOD', PChar(mhData.method));
        setValue('PATH_INFO', '');
        setValue('PATH_TRANSLATED', '');
        setValue('PATH', GetEnvironmentVariable('PATH'));

        //get client information
        connectionInfo := MHD_get_connection_info(
            mhData.connection,
            MHD_CONNECTION_INFO_CLIENT_ADDRESS
        );

        ipAddress := NetAddrToStr(connectionInfo^.client_addr^.sin_addr);
        //get client IP
        setValue('REMOTE_ADDR', ipAddress);
        //get client port
        setValue('REMOTE_PORT', inttostr(connectionInfo^.client_addr^.sin_port));
        //this should be hostname of client but since reverse-name lookup
        //is expensive, just use IP address instead. This does not violates RFC 3875
        setValue('REMOTE_HOST', ipAddress);
        //assume not authorized, this will be handled by http authentication middleware
        setValue('REMOTE_USER', '');
        setValue('AUTH_TYPE', '');
        setValue('REMOTE_IDENT', '');

        //we will build HTTP header environment inside extractHeaders
        //note: while libmicrohttpd allows to get request header and query string
        //with same function callback using MHD_HEADER_KIND or MHD_GET_ARGUMENT_KIND,
        //there is no way to indicate if current data is header or query string,
        //so we need separate to calls
        MHD_get_connection_values (
            mhData.connection,
            MHD_HEADER_KIND,
            @extractHeaders,
            //pass current class instance so we can retrieve it
            //from cls pointer of extractHeaders() function
            self
        );

        //we will build query string inside extractQueryStrs
        //initialize with empty string first
        setValue('QUERY_STRING', '');

        MHD_get_connection_values (
            mhData.connection,
            MHD_GET_ARGUMENT_KIND,
            @extractQueryStrs,
            //pass current class instance so we can retrieve it
            //from cls pointer of extractQueryStrs() function
            self
        );

        setValue('REQUEST_URI', PChar(mhData.url) + '?' + getValue('QUERY_STRING'));
    end;

end.

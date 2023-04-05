{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2022 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit MoremoreKeyValuePairImpl;

interface

{$MODE DELPHI}
{$H+}

uses

    StreamAdapterIntf,
    KeyValuePairImpl,
    mormot.core.base,
    mormot.net.http,
    HttpSvrConfigTypes;

type

    TMoremoreData = record
        ctxt : THttpServerRequestAbstract;
        //this will be set by application
        serverConfig : THttpSvrConfig;
    end;

    (*!------------------------------------------------
     * key value pair class having capability
     * to retrieve CGI environment variable from Moremore THttpServerGeneric
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *--------------------------------------------------*)
    TMoremoreKeyValuePair = class(TKeyValuePair)
    private
        procedure initEnvVars(const webData : TMoremoreData);
    public
        constructor create(const webData : TMoremoreData);
    end;

implementation

uses

    SysUtils;

    constructor TMoremoreKeyValuePair.create(const webData : TMoremoreData);
    begin
        inherited create();
        initEnvVars(webData);
    end;

    // retrieve query string part from url '/echo?var1=1&var2=2'
    // output 'var1=1&var2=2'
    function getQueryString(url : RawUTF8) : string;
    var qryStrStart : integer;
    begin
        qryStrStart := pos('?', url);
        if qryStrStart > 0 then
        begin
            // +1 to skip ? character
            result := copy(url, qryStrStart + 1);
        end else
        begin
            result := '';
        end;
    end;

    procedure TMoremoreKeyValuePair.initEnvVars(const webData : TMoremoreData);
    begin
        setValue('GATEWAY_INTERFACE', 'CGI/1.1');
        setValue('SERVER_ADMIN', webData.serverConfig.serverAdmin);
        setValue('SERVER_NAME', webData.serverConfig.serverName);
        setValue('SERVER_ADDR', webData.serverConfig.host);
        setValue('SERVER_PORT', intToStr(webData.serverConfig.port));
        setValue('SERVER_SOFTWARE', webData.serverConfig.serverSoftware);
        setValue('DOCUMENT_ROOT', webData.serverConfig.documentRoot);
        setValue('SERVER_PROTOCOL', 'HTTP/1.1');

        setValue('REQUEST_METHOD', webData.ctxt.method);
        setValue('PATH_INFO', '');
        setValue('PATH_TRANSLATED', '');
        setValue('PATH', GetEnvironmentVariable('PATH'));

        setValue('REMOTE_ADDR', webData.ctxt.RemoteIP);
        setValue('REMOTE_PORT', '');
        setValue('REMOTE_HOST', webData.ctxt.RemoteIP);
        setValue('REMOTE_USER', webData.ctxt.AuthenticatedUser);
        setValue('AUTH_TYPE', '');
        setValue('REMOTE_IDENT', '');
        setValue('QUERY_STRING', getQueryString(webData.ctxt.url));
        setValue('REQUEST_URI', webData.ctxt.url);
    end;

end.

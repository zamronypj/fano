{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit HttpClientImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    InjectableObjectImpl,
    HttpGetClientIntf,
    HttpPostClientIntf,
    HttpPutClientIntf,
    HttpDeleteClientIntf,
    HttpHeadClientIntf;

type

    (*!------------------------------------------------
     * basic HTTP client having capability to send
     * GET, POST, PUT, DELETE and HEAD
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    THttpClient = class(
        TInjectableObject,
        IHttpGetClient,
        IHttpPostClient,
        IHttpPutClient,
        IHttpDeleteClient,
        IHttpHeadClient
    )
    private
        fGetClient : IHttpGetClient;
        fPostClient : IHttpPostClient;
        fPutClient : IHttpPutClient;
        fDeleteClient : IHttpDeleteClient;
        fHeadClient : IHttpHeadClient;
    public
        constructor create(
            const getClient : IHttpGetClient;
            const postClient : IHttpPostClient;
            const putClient : IHttpPutClient;
            const deleteClient : IHttpDeleteClient;
            const headClient : IHttpHeadClient
        );
        destructor destroy(); override;

        property httpGet : IHttpGetClient read fGetClient implements IHttpGetClient;
        property httpPost : IHttpPostClient read fPostClient implements IHttpPostClient;
        property httpPut : IHttpPutClient read fPutClient implements IHttpPutClient;
        property httpDelete : IHttpDeleteClient read fDeleteClient implements IHttpDeleteClient;
        property httpHead : IHttpHeadClient read fHeadClient implements IHttpHeadClient;

    end;

implementation

    constructor THttpClient.create(
        const getClient : IHttpGetClient;
        const postClient : IHttpPostClient;
        const putClient : IHttpPutClient;
        const deleteClient : IHttpDeleteClient;
        const headClient : IHttpHeadClient
    );
    begin
        fGetClient := getClient;
        fPostClient := postClient;
        fPutClient := putClient;
        fDeleteClient := deleteClient;
        fHeadClient := headClient;
    end;

    destructor THttpClient.destroy();
    begin
        inherited destroy();
        fGetClient := nil;
        fPostClient := nil;
        fPutClient := nil;
        fDeleteClient := nil;
        fHeadClient := headClient;
    end;

end.

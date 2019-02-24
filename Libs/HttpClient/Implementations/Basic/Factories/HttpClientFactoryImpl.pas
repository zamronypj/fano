{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit HttpClientFactoryImpl;

interface

{$MODE OBJFPC}

uses

    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl;

type
    (*!------------------------------------------------
     * THttpClient factory class
     *------------------------------------------------
     * This class can serve as factory class for THttpClient
     * and also can be injected into dependency container
     * directly to build THttpClient class
     *-------------------------------------------------
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    THttpClientFactory = class(TFactory)
    private
        fGetClientFactory : IDependencyFactory;
        fPostClientFactory : IDependencyFactory;
        fPutClientFactory : IDependencyFactory;
        fDeleteClientFactory : IDependencyFactory;
        fHeadClientFactory : IDependencyFactory;
    public
        constructor create(
            getClientFactory : IDependencyFactory;
            postClientFactory : IDependencyFactory;
            putClientFactory : IDependencyFactory;
            deleteClientFactory : IDependencyFactory;
            headClientFactory : IDependencyFactory
        );

        destructor destroy(); override;

        (*!---------------------------------------------------
         * build class instance
         *----------------------------------------------------
         * @param container dependency container instance
         *----------------------------------------------------
         * This is implementation of IDependencyFactory
         *---------------------------------------------------*)
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses

    HttpClientImpl;

    constructor THttpClientFactory.create(
        getClientFactory : IDependencyFactory;
        postClientFactory : IDependencyFactory;
        putClientFactory : IDependencyFactory;
        deleteClientFactory : IDependencyFactory;
        headClientFactory : IDependencyFactory
    );
    begin
        fGetClientFactory := getClientFactory;
        fPostClientFactory := postClientFactory;
        fPutClientFactory := putClientFactory;
        fDeleteClientFactory := deleteClientFactory;
        fHeadClientFactory := headClientFactory;
    end;

    destructor THttpClientFactory.destroy();
    begin
        inherited destroy();
        fGetClientFactory := nil;
        fPostClientFactory := nil;
        fPutClientFactory := nil;
        fDeleteClientFactory := nil;
        fHeadClientFactory := nil;
    end;

    (*!---------------------------------------------------
     * build class instance
     *----------------------------------------------------
     * @param container dependency container instance
     *---------------------------------------------------*)
    function THttpClientFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := THttpClient.create(
            fGetClientFactory.build(container) as IHttpGetClient,
            fPostClientFactory.build(container) as IHttpPostClient,
            fPutClientFactory.build(container) as IHttpPutClient,
            fDeleteClientFactory.build(container) as IHttpDeleteClient,
            fHeadClientFactory.build(container) as IHttpHeadClient
        );
    end;
end.

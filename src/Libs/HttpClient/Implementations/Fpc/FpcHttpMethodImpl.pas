{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FpcHttpMethodImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    fphttpclient,
    InjectableObjectImpl,
    ResponseStreamIntf,
    HttpClientHeadersIntf,
    HttpClientHandleAwareIntf,
    QueryStrBuilderIntf;

type

    (*!------------------------------------------------
     * base class for HTTP operation usng TFpHttpClient
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFpcHttpMethod = class(TInjectableObject, IHttpClientHeaders)
    protected
        fQueryStrBuilder : IQueryStrBuilder;
        fHttpClient : TFPHTTPClient;

    public

        (*!------------------------------------------------
         * constructor
         *-----------------------------------------------
         * @param headersInst instance class that can set headers
         * @param fStream stream instance that will be used to
         *                store data coming from server
         *-----------------------------------------------*)
        constructor create(
            const headersInst : IHttpClientHeaders;
            const queryStrBuilder : IQueryStrBuilder
        );

        (*!------------------------------------------------
         * destructor
         *-----------------------------------------------*)
        destructor destroy(); override;

        (*!------------------------------------------------
         *  add header
         *-----------------------------------------------
         * @param aheader string contain header name
         * @param avalue string contain header value
         * @return current instance
         *-----------------------------------------------*)
        function add(const aheader : string; const avalue : string) : IHttpClientHeaders;

        (*!------------------------------------------------
         *  apply added header
         *-----------------------------------------------
         * @return current instance
         *-----------------------------------------------*)
        function apply() : IHttpClientHeaders;

    end;

implementation

uses

    EHttpClientErrorImpl;



    (*!------------------------------------------------
     * constructor
     *-----------------------------------------------
     * @param fStream stream instance that will be used to
     *                store data coming from server
     *-----------------------------------------------*)
    constructor TFpcHttpMethod.create(
        const queryStrBuilder : IQueryStrBuilder
    );
    begin
        fHttpClient := TFPHTTPClient.create(nil);
        fQueryStrBuilder := queryStrBuilder;
    end;

    (*!------------------------------------------------
     * destructor
     *-----------------------------------------------*)
    destructor TFpcHttpMethod.destroy();
    begin
        fQueryStrBuilder := nil;
        fHttpClient.free();
        inherited destroy();
    end;

    (*!------------------------------------------------
     *  add header
     *-----------------------------------------------
     * @param aheader string contain header name
     * @param avalue string contain header value
     * @return current instance
     *-----------------------------------------------*)
    function TFpcHttpMethod.add(const aheader : string; const avalue : string) : IHttpClientHeaders;
    begin
        fHttpClient.addHeader(aheader, avalue);
        result := self;
    end;

    (*!------------------------------------------------
     *  apply added header
     *-----------------------------------------------
     * @return current instance
     *-----------------------------------------------*)
    function TFpcHttpMethod.apply() : IHttpClientHeaders;
    begin
        //do nothing as not relevant here
        result := self;
    end;

end.

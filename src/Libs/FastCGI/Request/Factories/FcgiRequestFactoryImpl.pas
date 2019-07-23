{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FcgiRequestFactoryImpl;

interface

{$MODE OBJFPC}

uses

    EnvironmentIntf,
    RequestIntf,
    RequestFactoryIntf,
    FcgiRequestIdAwareIntf,
    FcgiStdInStreamAwareIntf;

type
    (*!------------------------------------------------
     * factory class for FastCGI Request
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiRequestFactory = class(TInterfacedObject, IRequestFactory)
    private
        fRequestIdAware : IFcgiRequestIdAware;
        fStdInAware : IFcgiStdInStreamAware;
    public
        constructor create(
            const requestIdAware : IFcgiRequestIdAware;
            const stdInAware : IFcgiStdInStreamAware;
        );
        destructor destroy; override;
        function build(const env : ICGIEnvironment) : IRequest;
    end;

implementation

uses
    RequestImpl,
    HashListImpl,
    MultipartFormDataParserImpl,
    UploadedFileCollectionFactoryImpl,
    UploadedFileCollectionWriterFactoryImpl,
    StdInReaderIntf,
    StdInFromStreamImpl;

    constructor TFcgiRequestFactory.create(
        const requestIdAware : IFcgiRequestIdAware;
        const stdInAware : IFcgiStdInStreamAware;
    );
    begin
        fRequestIdAware := requestIdAware;
        fStdInAware := stdInStreamAware;
    end;

    destructor TFcgiRequestFactory.destroy();
    begin
        inherited destroy();
        fRequestIdAware := nil;
        fStdInAware := nil;
    end;

    function TFcgiRequestFactory.build(const env : ICGIEnvironment) : IRequest;
    var arequest : IRequest;
    begin
        arequest := TRequest.create(
            env,
            THashList.create(),
            THashList.create(),
            THashList.create(),
            TMultipartFormDataParser.create(
                TUploadedFileCollectionWriterFactory.create()
            ),
            TStdInReaderFromStream.create(fStdInAware.getStdIn())
        );
        result := TFcgiRequest.create(fRequestIdAware.getRequestId(), arequest);
    end;
end.

{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ScgiRequestFactoryImpl;

interface

{$MODE OBJFPC}

uses

    EnvironmentIntf,
    RequestIntf,
    RequestFactoryIntf,
    StdInStreamAwareIntf;

type
    (*!------------------------------------------------
     * factory class for SCGI Request
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TScgiRequestFactory = class(TInterfacedObject, IRequestFactory)
    private
        fStdInAware : IStdInStreamAware;
    public
        constructor create(const stdInAware : IStdInStreamAware);
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

    constructor TScgiRequestFactory.create(const stdInAware : IStdInStreamAware);
    begin
        fStdInAware := stdInStreamAware;
    end;

    destructor TScgiRequestFactory.destroy();
    begin
        fStdInAware := nil;
        inherited destroy();
    end;

    function TScgiRequestFactory.build(const env : ICGIEnvironment) : IRequest;
    var arequest : IRequest;
    begin
        result := TRequest.create(
            env,
            THashList.create(),
            THashList.create(),
            THashList.create(),
            TMultipartFormDataParser.create(
                TUploadedFileCollectionWriterFactory.create()
            ),
            TStdInReaderFromStream.create(fStdInAware.getStdIn())
        );
    end;
end.

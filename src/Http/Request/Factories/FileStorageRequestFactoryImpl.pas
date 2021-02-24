{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2021 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FileStorageRequestFactoryImpl;

interface

{$MODE OBJFPC}

uses
    EnvironmentIntf,
    StdInIntf,
    RequestIntf,
    RequestFactoryIntf,
    StorageIntf;

type

    (*!------------------------------------------------
     * factory class for TRequest with File Storage
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFileStorageRequestFactory = class(TInterfacedObject, IRequestFactory)
    private
        fStorage : IStorage;
    public
        constructor create(const storageInst : IStorage);
        function build(const env : ICGIEnvironment; const stdIn : IStdIn) : IRequest;
    end;

implementation

uses

    RequestImpl,
    RequestHeadersImpl,
    HashListImpl,
    MultipartFormDataParserImpl,
    UploadedFileCollectionFactoryImpl,
    FileStorageUploadedFileCollectionWriterFactoryImpl,
    StdInReaderImpl,
    SimpleStdInReaderImpl,
    UriImpl;

    constructor TFileStorageRequestFactory.create(const storageInst : IStorage);
    begin
        fStorage := storageInst;
    end;

    function TFileStorageRequestFactory.build(
        const env : ICGIEnvironment;
        const stdIn : IStdIn
    ) : IRequest;
    begin
        result := TRequest.create(
            TUri.create(env),
            TRequestHeaders.create(env),
            env,
            THashList.create(),
            THashList.create(),
            THashList.create(),
            TMultipartFormDataParser.create(
                TFileStorageUploadedFileCollectionWriterFactory.create(fStorage)
            ),
            stdIn
        );
    end;
end.

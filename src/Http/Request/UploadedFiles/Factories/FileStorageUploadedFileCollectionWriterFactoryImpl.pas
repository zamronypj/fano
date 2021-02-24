{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2021 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FileStorageUploadedFileCollectionWriterFactoryImpl;

interface

{$MODE OBJFPC}

uses

    DependencyIntf,
    DependencyContainerIntf,
    UploadedFileCollectionWriterIntf,
    UploadedFileCollectionWriterFactoryIntf,
    StorageIntf,
    FactoryImpl;

type
    (*!------------------------------------------------
     * factory class TUploadedFileCollection with
     * File Storage uitlity
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFileStorageUploadedFileCollectionWriterFactory = class(TFactory, IUploadedFileCollectionWriterFactory)
    private
        fStorage : IStorage;
    public
        constructor create(const storageInst : IStorage);
        function build(const container : IDependencyContainer) : IDependency; override;
        function createCollectionWriter() : IUploadedFileCollectionWriter;
    end;

implementation

uses

    UploadedFileCollectionImpl,
    FileStorageUploadedFileFactoryImpl,
    HashListImpl;

    constructor TFileStorageUploadedFileCollectionWriterFactory.create(
        const storageInst : IStorage
    );
    begin
        fStorage := storageInst;
    end;

    function TFileStorageUploadedFileCollectionWriterFactory.build(
        const container : IDependencyContainer
    ) : IDependency;
    begin
        result := createCollectionWriter() as IDependency;
    end;

    function TFileStorageUploadedFileCollectionWriterFactory.createCollectionWriter() : IUploadedFileCollectionWriter;
    begin
        result := TUploadedFileCollection.create(
            THashList.create(),
            TFileStorageUploadedFileFactory.create(fStorage)
        );
    end;
end.

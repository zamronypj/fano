{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2021 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FileStorageUploadedFileFactoryImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    DependencyIntf,
    UploadedFileIntf,
    UploadedFileFactoryIntf,
    StorageIntf,
    InjectableObjectImpl;

type

    (*!------------------------------------------------
     * factory class TFileStorageUploadedFile
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFileStorageUploadedFileFactory = class(TInjectableObject, IUploadedFileFactory)
    private
        fStorage : IStorage;
    public
        function storage(const storageInst : IStorage) : TFileStorageUploadedFileFactory;

        (*!----------------------------------------
         * create instance of IUploadedFile
         *-----------------------------------------
         * @param content content of uploaded file
         * @param contentType content type of uploaded file
         * @param origFilename original filename as uploaded by user
         *-----------------------------------------
         * We will create temporary file to hold uploaded
         * file content.
         *-----------------------------------------*)
        function createUploadedFile(
            const content : string;
            const contentType : string;
            const origFilename : string
        ) : IUploadedFile;
    end;

implementation

uses

    UploadedFileImpl,
    FileStorageUploadedFileImpl;

    function TFileStorageUploadedFileFactory.storage(
        const storageInst : IStorage
    ) : TFileStorageUploadedFileFactory;
    begin
        fStorage := storageInst;
        result := self;
    end;

    (*!----------------------------------------
     * create instance of IUploadedFile
     *-----------------------------------------
     * @param content content of uploaded file
     * @param contentType content type of uploaded file
     * @param origFilename original filename as uploaded by user
     *-----------------------------------------
     * We will create temporary file to hold uploaded
     * file content.
     *-----------------------------------------*)
    function TFileStorageUploadedFileFactory.createUploadedFile(
        const content : string;
        const contentType : string;
        const origFilename : string
    ) : IUploadedFile;
    begin
        result := TFileStorageUploadedFile.create(
            TUploadedFile.create(
                content,
                contentType,
                origFilename
            ),
            fStorage
        );
    end;
end.

{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2021 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FileStorageUploadedFileImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    InjectableObjectImpl,
    UploadedFileIntf,
    StorageIntf;

type

    (*!------------------------------------------------
     * decorator class having capability to store
     * HTTP file upload using File Storage library
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFileStorageUploadedFile = class(TInterfacedObject, IUploadedFile)
    private
        fActualUploadedFile : IUploadedFile;
        fStorage : IStorage;
    public
        (*!----------------------------------------
         * constructor
         *-----------------------------------------
         * @param actualUploadedFile decorated uploaded file
         * @param storage file storage utility
         * @throw EArgumenNilException when input params nil
         *-----------------------------------------*)
        constructor create(
            const actualUploadedFile : IUploadedFile;
            const storage : IStorage
        );

        (*!------------------------------------------------
         * move uploaded file to specified
         *-------------------------------------------------
         * @param string target path
         * @return current instance
         * @throws EInvalidOperation
         *------------------------------------------------
         * Implementor must raise exception when moveTo()
         * called multiple time
         * Implementor must check for file permission
         *------------------------------------------------*)
        function moveTo(const targetPath : string) : IUploadedFile;

        (*!------------------------------------------------
         * get uploaded file size
         *-------------------------------------------------
         * @return size in bytes of uploaded file
         *------------------------------------------------*)
        function size() : int64;

        (*!------------------------------------------------
         * get client side filename
         *-------------------------------------------------
         * @return string original filename as uploaded by client
         *------------------------------------------------*)
        function getClientFilename() : string;

        (*!------------------------------------------------
         * get client side MIME type
         *-------------------------------------------------
         * @return string original MIME type as uploaded by client
         *------------------------------------------------*)
        function getClientMediaType() : string;

        (*!------------------------------------------------
         * get temporary filepath
         *-------------------------------------------------
         * @return string path of tmp file
         *------------------------------------------------*)
        function getTmpFilename() : string;
    end;

implementation

uses

    SysUtils;

resourcestring

    sErrNilUploadedFileInst = 'Nil IUploadedFile instance';
    sErrNilFileStorageInst = 'Nil IStorage instance';

    (*!----------------------------------------
     * constructor
     *-----------------------------------------
     * @param actualUploadedFile decorated uploaded file
     * @param storage file storage utility
     *-----------------------------------------*)
    constructor TFileStorageUploadedFile.create(
        const actualUploadedFile : IUploadedFile;
        const storage : IStorage
    );
    begin
        fActualUploadedFile := actualUploadedFile;
        fStorage := storage;

        if (fActualUploadedFile = nil) then
        begin
            raise EArgumentNilException.create(sErrNilUploadedFileInst);
        end;

        if (fStorage = nil) then
        begin
            raise EArgumentNilException.create(sErrNilFileStorageInst);
        end;
    end;

    (*!------------------------------------------------
     * move uploaded file to specified
     *-------------------------------------------------
     * @param string target path
     * @return current instance
     * @throws EInvalidOperation
     *------------------------------------------------*)
    function TFileStorageUploadedFile.moveTo(const targetPath : string) : IUploadedFile;
    begin
        fStorage.move(fActualUploadedFile.getTmpFilename(), targetPath);
        result := self;
    end;

    (*!------------------------------------------------
     * get uploaded file size
     *-------------------------------------------------
     * @return size in bytes of uploaded file
     *------------------------------------------------*)
    function TFileStorageUploadedFile.size() : int64;
    begin
        result := fActualUploadedFile.size();
    end;

    (*!------------------------------------------------
     * get client side filename
     *-------------------------------------------------
     * @return string original filename as uploaded by client
     *------------------------------------------------*)
    function TFileStorageUploadedFile.getClientFilename() : string;
    begin
        result := fActualUploadedFile.getClientFilename();
    end;

    (*!------------------------------------------------
     * get client side MIME type
     *-------------------------------------------------
     * @return string original MIME type as uploaded by client
     *------------------------------------------------*)
    function TFileStorageUploadedFile.getClientMediaType() : string;
    begin
        result := fActualUploadedFile.getClientMediaType();
    end;

    (*!------------------------------------------------
     * get temporary filepath
     *-------------------------------------------------
     * @return string path of tmp file
     *------------------------------------------------*)
    function TFileStorageUploadedFile.getTmpFilename() : string;
    begin
        result := fActualUploadedFile.getTmpFilename();
    end;
end.

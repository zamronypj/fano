{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit UploadedFileCollectionImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    UploadedFileIntf,
    UploadedFileCollectionIntf,
    UploadedFileCollectionWriterIntf,
    UploadedFileFactoryIntf,
    ListIntf;

type

    (*!------------------------------------------------
     * basic class having capability as
     * contain array of IUploadedFile instance
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TUploadedFileCollection = class(TInterfacedObject, IUploadedFileCollection, IUploadedFileCollectionWriter)
    private
        uploadedFiles : IList;
        uploadedFileFactory : IUploadedFileFactory;

        procedure clearUploadedFiles(const listInst : IList);
    public

        constructor create(
            const listInst : IList;
            const factory : IUploadedFileFactory
        );
        destructor destroy(); override;

        (*!------------------------------------------------
         * get total uploaded file in collection
         *-------------------------------------------------
         * @return number of item in collection
         *------------------------------------------------*)
        function count() : integer;

        (*!------------------------------------------------
         * get IUploadedFile instance by name
         *-------------------------------------------------
         * @return IUploadedFile instance
         *------------------------------------------------*)
        function getUploadedFile(const key : shortstring) : IUploadedFile;

        (*!------------------------------------------------
         * get IUploadedFile instance by index
         *-------------------------------------------------
         * @return IUploadedFile instance
         *------------------------------------------------*)
        function getUploadedFile(const indx : integer) : IUploadedFile;

        (*!-------------------------------------
         * Add content as IUploadedFile
         *--------------------------------------
         * @param key name of field
         * @param content content of file
         * @param contentType file content type
         * @param originalFilename original filename uploaded by user
         *--------------------------------------*)
        function add(
            const key : shortstring;
            const content : string;
            const contentType : string;
            const originalFilename : string
        ) : IUploadedFileCollectionWriter;
    end;

implementation

uses

    UploadedFileImpl;

type

    TUploadedFileArr = array of IUploadedFile;
    TUploadedFileRec = record
        key : shortstring;
        uploadedFilesCount : integer;
        uploadedFiles : TUploadedFileArr;
    end;
    PUploadedFileRec = ^TUploadedFileRec;

    constructor TUploadedFileCollection.create(
        const listInst : IList;
        const factory : IUploadedFileFactory
    );
    begin
        uploadedFiles := listInst;
        uploadedFileFactory := factory;
    end;

    destructor TUploadedFileCollection.destroy();
    begin
        inherited destroy();
        clearUploadedFiles(uploadedFiles);
        uploadedFiles := nil;
    end;

    procedure TUploadedFileCollection.clearUploadedFiles(const listInst : IList);
    var item : PUploadedFileRec;
        i : integer;
    begin
        for i:=listInst.count()-1 downto 0 do
        begin
            item := listInst.get(i);
            setLength(item^.key,0);
            item^.uploadedFiles := nil;
            dispose(item);
            listInst.delete(i);
        end;
    end;

    (*!------------------------------------------------
     * get total uploaded file in collection
     *-------------------------------------------------
     * @return number of item in collection
     *------------------------------------------------*)
    function TUploadedFileCollection.count() : integer;
    begin
        result := uploadedFiles.count();
    end;

    (*!------------------------------------------------
     * get IUploadedFile instance by name
     *-------------------------------------------------
     * @return IUploadedFile instance
     *------------------------------------------------*)
    function TUploadedFileCollection.getUploadedFile(const key : shortstring) : IUploadedFile;
    var item : PUploadedFileRec;
    begin
        result := nil;
        item := uploadedFiles.find(key);
        if (item <> nil) then
        begin
          //TODO: array is used so we can support multiple parameters with same name
          result := item^.uploadedFiles[0];
        end;
    end;

    (*!------------------------------------------------
     * get IUploadedFile instance by index
     *-------------------------------------------------
     * @return IUploadedFile instance
     *------------------------------------------------*)
    function TUploadedFileCollection.getUploadedFile(const indx : integer) : IUploadedFile;
    var item : PUploadedFileRec;
    begin
        item := uploadedFiles.get(indx);
        result := item^.uploadedFiles[0];
    end;

    (*!-------------------------------------
     * Add content as IUploadedFile
     *--------------------------------------
     * @param key key name
     * @param content content of file
     * @param contentType file content type
     * @param originalFilename original filename uploaded by user
     *--------------------------------------
     * RFC 7578 requires that form data with
     * same name do not coalesce. So if we have
     * multiple file upload, we will keep them
     * in array
     *--------------------------------------*)
    function TUploadedFileCollection.add(
        const key : shortstring;
        const content : string;
        const contentType : string;
        const originalFilename : string
    ) : IUploadedFileCollectionWriter;
    var item : PUploadedFileRec;
    begin
        item := uploadedFiles.find(key);
        if (item = nil) then
        begin
            new(item);
            item^.key := key;
            item^.uploadedFilesCount := 0;
            //pre allocated array
            setLength(item^.uploadedFiles, length(item^.uploadedFiles) + 10);
            uploadedFiles.add(key, item);
        end else
        begin
            if (length(item^.uploadedFiles) <= item^.uploadedFilesCount) then
            begin
                //resize array
                setLength(item^.uploadedFiles, length(item^.uploadedFiles) + 10);
            end;
        end;

        item^.uploadedFiles[item^.uploadedFilesCount] := uploadedFilefactory.createUploadedFile(
            content,
            contentType,
            originalFilename
        );
        inc(item^.uploadedFilesCount);
        result := self;
    end;
end.

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

        procedure clearUploadedFiles(const listInst : IList);
    public

        constructor create(const listInst : IList);
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

    TUploadedFileRec = record
        key : shortstring;
        uploadedFile : IUploadedFile;
    end;
    PUploadedFileRec = ^TUploadedFileRec;

    constructor TUploadedFileCollection.create(const listInst : IList);
    begin
        uploadedFiles := listInst;
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
            item^.uploadedFile := nil;
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
        item := uploadedFiles.find(key);
        result := item^.uploadedFile;
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
        result := item^.uploadedFile;
    end;

    (*!-------------------------------------
     * Add content as IUploadedFile
     *--------------------------------------
     * @param key key name
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
    var item : PUploadedFileRec;
    begin
        new(item);
        item^.key := key;
        item^.uploadedFile := TUploadedFile.create(
            content,
            contentType,
            originalFilename
        );
        uploadedFiles.add(key, item);
        result := self;
    end;
end.
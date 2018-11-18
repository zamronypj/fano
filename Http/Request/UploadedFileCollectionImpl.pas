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

uses

    UploadedFileIntf,
    UploadedFileCollectionIntf;

type

    (*!------------------------------------------------
     * basic class having capability as
     * contain array of IUploadedFile instance
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TUploadedFileCollection = class(TInterfacedObject, IUploadedFileCollection)
    public
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

    end;

implementation

    (*!------------------------------------------------
     * get total uploaded file in collection
     *-------------------------------------------------
     * @return number of item in collection
     *------------------------------------------------*)
    function TUploadedFileCollection.count() : integer;
    begin
        //TODO: implement count()
        result := 0;
    end;

    (*!------------------------------------------------
     * get IUploadedFile instance by name
     *-------------------------------------------------
     * @return IUploadedFile instance
     *------------------------------------------------*)
    function TUploadedFileCollection.getUploadedFile(const key : shortstring) : IUploadedFile;
    begin
        //TODO: implement getuploadedFile()
        result := 0;
    end;

    (*!------------------------------------------------
     * get IUploadedFile instance by index
     *-------------------------------------------------
     * @return IUploadedFile instance
     *------------------------------------------------*)
    function TUploadedFileCollection.getUploadedFile(const indx : integer) : IUploadedFile;
    begin
        //TODO: implement getuploadedFile()
        result := 0;
    end;
end.
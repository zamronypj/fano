{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit UploadedFileCollectionIntf;

interface

{$MODE OBJFPC}

uses

    UploadedFileIntf;

type

    (*!------------------------------------------------
     * interface for any class having capability as
     * contain array of IUploadedFile instance
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IUploadedFileCollection = interface
        ['{116083C1-4484-489D-AE15-5565B29CE802}']

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

end.
{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit UploadedFileImpl;

interface

{$MODE OBJFPC}
{$H+}

type

    (*!------------------------------------------------
     * interface for any class having capability as
     * to handle HTTP file upload
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TUploadedFile= class(TInterfacedObject, IUploadedFile)
    private
    public

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
    end;

implementation

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
    begin

    end;

    (*!------------------------------------------------
     * get uploaded file size
     *-------------------------------------------------
     * @return size in bytes of uploaded file
     *------------------------------------------------*)
    function size() : int64;
    begin

    end;

    (*!------------------------------------------------
     * get client side filename
     *-------------------------------------------------
     * @return string original filename as uploaded by client
     *------------------------------------------------*)
    function getClientFilename() : string;
    begin

    end;

    (*!------------------------------------------------
     * get client side MIME type
     *-------------------------------------------------
     * @return string original MIME type as uploaded by client
     *------------------------------------------------*)
    function getClientMediaType() : string;
    begin

    end;

end.

{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit MultipartFormDataParserIntf;

interface

{$MODE OBJFPC}
{$H+}

uses

    KeyValueTypes,
    ListIntf,
    EnvironmentIntf,
    UploadedFileCollectionWriterIntf;

type

    (*!----------------------------------------------
     * interface for any class having capability as
     * parse multipart/form-data request
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IMultipartFormDataParser = interface
        ['{F0C5A45D-B8F0-4CF6-86FD-84C60C17E67E}']

        (*!----------------------------------------
         * Read POST data in standard input and parse
         * it and store parsed data in body request parameter
         * and uploaded files (if any). If not file upload
         * then TNullUploadedFileCollection instance is return
         *------------------------------------------
         * @param env CGI environment variable
         * @param body instance of IList that will store
         *             parsed body parameter
         * @param uploadedFiles instance of uploaded file collection writer
         * @return current instance
         *------------------------------------------*)
        function parse(
            const env : ICGIEnvironment;
            const body : IList;
            out uploadedFiles : IUploadedFileCollectionWriter
        ) : IMultipartFormDataParser;
    end;

implementation
end.

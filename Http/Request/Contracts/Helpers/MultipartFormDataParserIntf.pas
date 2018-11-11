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

uses

    HashIntf,
    UploadedFileCollectionIntf;

type

    (*!----------------------------------------------
     * interface for any class having capability as
     * parse multipart/form-data request
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IMultipartFormDataParser = interface
        ['{F0C5A45D-B8F0-4CF6-86FD-84C60C17E67E}']

        function parse(
            const body : IHashList;
            const uploadedFiles : IUploadedFileCollection) : IMultipartFormDataParser;
    end;

implementation
end.

{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2021 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit AmazonS3DirectoryImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    FileIntf,
    DirectoryIntf,
    aws_s3;

type

    (*!------------------------------------------------
     * class having capability to read and get stats of
     * bucket in Amazon S3
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TAmazonS3Directory = class (TInterfacedObject, IDirectory)
    private
        fDirPath : string;
        fS3Service : IS3Service;
    public
        constructor create(const s3Svc: IS3Service; const dirPath : string);

        (*!------------------------------------------------
         * list content of directory
         *-----------------------------------------------
         * @param filterCriteria filter criteria
         * @return content of file
         *-----------------------------------------------*)
        function list(const filterCriteria : string) : IFileArray;

    end;

implementation

uses

    SysUtils,
    AmazonS3FileImpl;

    constructor TAmazonS3Directory.create(const s3Svc: IS3Service; const dirPath : string);
    begin
        fS3Service := s3Svc;
        fDirPath := dirPath;
    end;

    (*!------------------------------------------------
     * list content of directory
     *-----------------------------------------------
     * @param filterCriteria filter criteria
     * @return content of file
     *-----------------------------------------------*)
    function TAmazonS3Directory.list(const filterCriteria : string) : IFileArray;
    var totFile : integer;
        objs : IS3Objects;
    begin
        //TODO: retriev bucket list
        result := nil;
        // objs := fS3Service.Buckets.listObjects(filterCriteria);
        // SetLength(result, objs.count);
        // for totFile := 0 to objs.count-1 do
        // begin
        //     result[totFile] := TAmazonS3File.create(fS3Service, objs[i].name);
        // end;
    end;
end.

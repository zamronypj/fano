{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2021 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit AmazonS3FileImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    StreamAdapterIntf,
    FileIntf,
    aws_s3_contracts;

type

    (*!------------------------------------------------
     * class having capability to read, write and
     * get stats of file stored in Amazon S3
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TAmazonS3File = class (TInterfacedObject, IFile)
    private
        fS3Service : IS3Service;
        fFilePath : string;
        fBucketName : string;
        fContentType : string;
    public
        constructor create(
            const s3Svc : IS3Service;
            const bucketName : string;
            const filePath : string;
            const contentType : string
        );

        (*!------------------------------------------------
         * retrieve content of a file as string
         *-----------------------------------------------
         * @param filePath file path to retrieve
         * @return content of file
         *-----------------------------------------------*)
        function get() : string;

        (*!------------------------------------------------
         * write content to file
         *-----------------------------------------------
         * @param cnt content to write
         *-----------------------------------------------*)
        procedure put(const cnt : string);

        property content : string read get write put;

        (*!------------------------------------------------
         * retrieve content of a file as string
         *-----------------------------------------------
         * @return content of file
         *-----------------------------------------------*)
        function getStream() : IStreamAdapter;

        (*!------------------------------------------------
         * write content to file
         *-----------------------------------------------
         * @param filePath file path to write
         * @param cnt content to write
         *-----------------------------------------------*)
        procedure putStream(const cnt : IStreamAdapter);

        property stream : IStreamAdapter read getStream write putStream;

        (*!------------------------------------------------
         * prepend content at begining of file
         *-----------------------------------------------
         * @param cnt content to write
         *-----------------------------------------------*)
        procedure prepend(const cnt : string);

        (*!------------------------------------------------
         * append content at end of file
         *-----------------------------------------------
         * @param cnt content to write
         *-----------------------------------------------*)
        procedure append(const cnt : string);

        (*!------------------------------------------------
         * copy file
         *-----------------------------------------------
         * @param dstPath destination file path
         *-----------------------------------------------*)
        procedure copy(const dstPath : string);


        (*!------------------------------------------------
         * get file size
         *-----------------------------------------------
         * @param filePath file path to check
         * @return size of file
         *-----------------------------------------------*)
        function size() : int64;

        (*!------------------------------------------------
         * get file last modified
         *-----------------------------------------------
         * @param filePath file path to check
         * @return last modified as unix timestamp
         *-----------------------------------------------*)
        function lastModified() : longint;
    end;


implementation

uses

    classes,
    sysutils,
    FileUtils,
    StreamAdapterImpl;

    constructor TAmazonS3File.create(
        const s3Svc : IS3Service;
        const bucketName : string;
        const filePath : string;
        const contentType : string
    );
    begin
        fS3Service := s3Svc;
        fBucketName := bucketName;
        fFilePath := filePath;
        fContentType := contentType;
    end;

    (*!------------------------------------------------
     * retrieve content of a file as string
     *-----------------------------------------------
     * @param filePath file path to retrieve
     * @return content of file
     *-----------------------------------------------*)
    function TAmazonS3File.get() : string;
    var bkt : IS3Bucket;
        strStream : TStream;
    begin
        strStream := TStringStream.create('');
        try
            bkt := fS3Service.buckets.get(fBucketName, fFilePath);
            bkt.objects.get(fBucketName, fFilePath)
                .stream.saveToStream(strStream);
            result := strStream.dataString();
        finally
            strStream.free();
        end;
    end;

    (*!------------------------------------------------
     * write content to file
     *-----------------------------------------------
     * @param content content to write
     *-----------------------------------------------*)
    procedure TAmazonS3File.put(const cnt : string);
    var strStream : TStringStream;
        bkt : IS3Bucket;
    begin
        strStream := TStringStream.create(cnt);
        try
            bkt := fS3Service.buckets.get(fBucketName, fFilePath);
            bkt.objects.Put(
                fBucketName,
                fContentType,
                TAWSStream.create(strStream),
                fFilePath
            );
        finally
            strStream.free();
        end;
    end;


    (*!------------------------------------------------
     * retrieve content of a file as string
     *-----------------------------------------------
     * @return content of file
     *-----------------------------------------------*)
    function TAmazonS3File.getStream() : IStreamAdapter;
    begin
        result := TStreamAdapter.create(TFileStream.create(fFilePath, fmOpenReadWrite));
    end;

    (*!------------------------------------------------
     * write content to file
     *-----------------------------------------------
     * @param filePath file path to write
     * @param content content to write
     *-----------------------------------------------*)
    procedure TAmazonS3File.putStream(const cnt : IStreamAdapter);
    var fStream : TFileStream;
        buff : pointer;
        byteRead, totRead : int64;
    begin
        fStream := TFileStream.create(fFilePath, fmCreate);
        try
            getMem(buff, 4096);
            try
                totRead := 0;
                repeat
                    byteRead := cnt.read(buff^, 4096);
                    fStream.WriteBuffer(buff^, byteRead);
                    totRead := totRead + byteRead;
                until (byteRead < 4096) and (totRead < cnt.size);
            finally
                freeMem(buff);
            end;
        finally
            fStream.free();
        end;
    end;


    (*!------------------------------------------------
     * prepend content at begining of file
     *-----------------------------------------------
     * @param cnt content to write
     *-----------------------------------------------*)
    procedure TAmazonS3File.prepend(const cnt : string);
    var fStream : TFileStream;
    begin
        fStream := TFileStream.create(fFilePath, fmOpenReadWrite);
        try
            fStream.Seek(0, soFromBeginning);
            fStream.WriteBuffer(cnt[1], length(cnt));
        finally
            fStream.free();
        end;
    end;

    (*!------------------------------------------------
     * append content at end of file
     *-----------------------------------------------
     * @param content content to write
     *-----------------------------------------------*)
    procedure TAmazonS3File.append(const cnt : string);
    var fStream : TFileStream;
    begin
        fStream := TFileStream.create(fFilePath, fmOpenReadWrite);
        try
            fStream.Seek(0, soEnd);
            fStream.WriteBuffer(cnt[1], length(cnt));
        finally
            fStream.free();
        end;
    end;

    (*!------------------------------------------------
     * copy file
     *-----------------------------------------------
     * @param dstPath destination file path
     *-----------------------------------------------*)
    procedure TAmazonS3File.copy(const dstPath : string);
    var strStream : TStringStream;
        bkt : IS3Bucket;
    begin
        bkt := fS3Service.Buckets.Get(fBucketName, fFilePath);
        bkt.Objects.Get(
            fBucketName,
            edtObjectSubResource.Text
  ).Stream.SaveToFile(fneFile.FileName);
    end;

    (*!------------------------------------------------
     * get file size
     *-----------------------------------------------
     * @param filePath file path to check
     * @return size of file
     *-----------------------------------------------*)
    function TAmazonS3File.size() : int64;
    var fStream : TFileStream;
    begin
        fStream := TFileStream.create(fFilePath, fmOpenRead);
        try
            result := fStream.Size;
        finally
            fStream.free();
        end;
    end;

    (*!------------------------------------------------
     * get file last modified
     *-----------------------------------------------
     * @param filePath file path to check
     * @return size of file
     *-----------------------------------------------*)
    function TAmazonS3File.lastModified() : longint;
    begin
        result := FileAge(fFilePath);
    end;

end.

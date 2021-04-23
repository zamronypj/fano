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
    aws_s3;

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
    public
        constructor create(const s3Svc : IS3Service; const filePath : string);

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
         * @param strContent content to write
         *-----------------------------------------------*)
        procedure put(const strContent : string);

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
         * @param strContent content to write
         *-----------------------------------------------*)
        procedure putStream(const strContent : IStreamAdapter);

        property stream : IStreamAdapter read getStream write putStream;

        (*!------------------------------------------------
         * prepend content at begining of file
         *-----------------------------------------------
         * @param strContent content to write
         *-----------------------------------------------*)
        procedure prepend(const strContent : string);

        (*!------------------------------------------------
         * append content at end of file
         *-----------------------------------------------
         * @param strContent content to write
         *-----------------------------------------------*)
        procedure append(const strContent : string);

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

    constructor TAmazonS3File.create(const s3Svc : IS3Service; const filePath : string);
    begin
        fS3Service := s3Svc;
        fFilePath := filePath;
    end;

    (*!------------------------------------------------
     * retrieve content of a file as string
     *-----------------------------------------------
     * @param filePath file path to retrieve
     * @return content of file
     *-----------------------------------------------*)
    function TAmazonS3File.get() : string;
    begin
        result := readFile(fFilePath);
    end;

    (*!------------------------------------------------
     * write content to file
     *-----------------------------------------------
     * @param content content to write
     *-----------------------------------------------*)
    procedure TAmazonS3File.put(const strContent : string);
    var fStream : TFileStream;
    begin
        fStream := TFileStream.create(fFilePath, fmCreate);
        try
            fStream.WriteBuffer(strContent[1], length(strContent));
        finally
            fStream.free();
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
    procedure TAmazonS3File.putStream(const strContent : IStreamAdapter);
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
                    byteRead := strContent.read(buff^, 4096);
                    fStream.WriteBuffer(buff^, byteRead);
                    totRead := totRead + byteRead;
                until (byteRead < 4096) and (totRead < strContent.size);
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
     * @param strContent content to write
     *-----------------------------------------------*)
    procedure TAmazonS3File.prepend(const strContent : string);
    var fStream : TFileStream;
    begin
        fStream := TFileStream.create(fFilePath, fmOpenReadWrite);
        try
            fStream.Seek(0, soFromBeginning);
            fStream.WriteBuffer(strContent[1], length(strContent));
        finally
            fStream.free();
        end;
    end;

    (*!------------------------------------------------
     * append content at end of file
     *-----------------------------------------------
     * @param content content to write
     *-----------------------------------------------*)
    procedure TAmazonS3File.append(const strContent : string);
    var fStream : TFileStream;
    begin
        fStream := TFileStream.create(fFilePath, fmOpenReadWrite);
        try
            fStream.Seek(0, soEnd);
            fStream.WriteBuffer(strContent[1], length(strContent));
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
    const WHOLE_STREAM = 0;
    var fStream, dstStream : TFileStream;
    begin
        fStream := TFileStream.create(fFilePath, fmOpenRead);
        try
            dstStream := TFileStream.create(dstPath, fmCreate);
            try
                fStream.Seek(0, soEnd);
                dstStream.copyFrom(fStream, WHOLE_STREAM);
            finally
                dstStream.free();
            end;
        finally
            fStream.free();
        end;
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

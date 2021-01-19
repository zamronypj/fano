{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2021 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit CompositeFileImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    StreamAdapterIntf,
    FileIntf;

type

    (*!------------------------------------------------
     * class having capability to
     * read, write and get stats of file from multipe IFile
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TCompositeFile = class (TInterfacedObject, IFile)
    private
        fFiles : IFileArray;
    public
        constructor create(const files : IFileArray);

        destructor destroy(); override;

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
         * @param content content to write
         *-----------------------------------------------*)
        procedure put(const content : string);

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
         * @param content content to write
         *-----------------------------------------------*)
        procedure putStream(const content : IStreamAdapter);

        property stream : IStreamAdapter read getStream write putStream;

        (*!------------------------------------------------
         * prepend content at begining of file
         *-----------------------------------------------
         * @param content content to write
         *-----------------------------------------------*)
        procedure prepend(const content : string);

        (*!------------------------------------------------
         * append content at end of file
         *-----------------------------------------------
         * @param content content to write
         *-----------------------------------------------*)
        procedure append(const content : string);

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

    constructor TCompositeFile.create(const files : IFileArray);
    var i : integer;
    begin
        setlength(fFiles, Length(files));
        for i := low(files) to high(files) do
        begin
            fFiles[i] := files[i];
        end;
    end;

    destructor TCompositeFile.destroy();
    var i : integer;
    begin
        for i := low(fFiles) to high(fFiles) do
        begin
            fFiles[i] := nil;
        end;
        fFiles := nil;
        inherited destroy();
    end;

    (*!------------------------------------------------
     * retrieve content of a file as string
     *-----------------------------------------------
     * @param filePath file path to retrieve
     * @return content of file
     *-----------------------------------------------*)
    function TCompositeFile.get() : string;
    begin
        result := '';
        if (length(fFiles) > 0) then
        begin
            result := fFiles[0].get();
        end;
    end;

    (*!------------------------------------------------
     * write content to file
     *-----------------------------------------------
     * @param content content to write
     *-----------------------------------------------*)
    procedure TCompositeFile.put(const content : string);
    var i : integer;
    begin
        for i := low(fFiles) to high(fFiles) do
        begin
            fFiles[i].put(content);
        end;
    end;


    (*!------------------------------------------------
     * retrieve content of a file as string
     *-----------------------------------------------
     * @return content of file
     *-----------------------------------------------*)
    function TCompositeFile.getStream() : IStreamAdapter;
    begin
        result := nil;
        if (length(fFiles) > 0) then
        begin
            result := fFiles[0].getStream();
        end;
    end;

    (*!------------------------------------------------
     * write content to file
     *-----------------------------------------------
     * @param filePath file path to write
     * @param content content to write
     *-----------------------------------------------*)
    procedure TCompositeFile.putStream(const content : IStreamAdapter);
    var i : integer;
    begin
        for i := low(fFiles) to high(fFiles) do
        begin
            fFiles[i].putStream(content);
        end;
    end;


    (*!------------------------------------------------
     * prepend content at begining of file
     *-----------------------------------------------
     * @param content content to write
     *-----------------------------------------------*)
    procedure TCompositeFile.prepend(const content : string);
    var i : integer;
    begin
        for i := low(fFiles) to high(fFiles) do
        begin
            fFiles[i].prepend(content);
        end;
    end;

    (*!------------------------------------------------
     * append content at end of file
     *-----------------------------------------------
     * @param content content to write
     *-----------------------------------------------*)
    procedure TCompositeFile.append(const content : string);
    var i : integer;
    begin
        for i := low(fFiles) to high(fFiles) do
        begin
            fFiles[i].append(content);
        end;
    end;

    (*!------------------------------------------------
     * copy file
     *-----------------------------------------------
     * @param dstPath destination file path
     *-----------------------------------------------*)
    procedure TCompositeFile.copy(const dstPath : string);
    var i : integer;
    begin
        for i := low(fFiles) to high(fFiles) do
        begin
            fFiles[i].copy(dstPath);
        end;
    end;


    (*!------------------------------------------------
     * get file size
     *-----------------------------------------------
     * @param filePath file path to check
     * @return size of file
     *-----------------------------------------------*)
    function TCompositeFile.size() : int64;
    begin
        result := 0;
        if (length(fFiles) > 0) then
        begin
            result := fFiles[0].size();
        end;
    end;

    (*!------------------------------------------------
     * get file last modified
     *-----------------------------------------------
     * @param filePath file path to check
     * @return size of file
     *-----------------------------------------------*)
    function TCompositeFile.lastModified() : longint;
    begin
        result := 0;
        if (length(fFiles) > 0) then
        begin
            result := fFiles[0].lastModified();
        end;
    end;

end.

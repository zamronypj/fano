{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2020 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit CompositeStorageImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    FileIntf,
    DirectoryIntf,
    StorageIntf,
    InjectableObjectImpl;

type

    (*!------------------------------------------------
     * interface for any class having capability to manage
     * local disk storage
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TCompositeStorage = class (TInjectableObject, IStorage)
    private
        fStorages : IStorageArray;
    public
        constructor create(const storages : array of IStorage);

        destructor destroy(); override;

        (*!------------------------------------------------
         * test if file or directory exists
         *-----------------------------------------------
         * @param path file path to check
         * @return true if file exists in filePath
         *-----------------------------------------------*)
        function exists(const path : string) : boolean;

        (*!------------------------------------------------
         * get file
         *-----------------------------------------------
         * @param filePath file path to retrieve
         * @return instance of file
         *-----------------------------------------------*)
        function getFile(const path : string) : IFile;

        (*!------------------------------------------------
         * test if path is file
         *-----------------------------------------------
         * @param path file path to retrieve
         * @return boolean
         *-----------------------------------------------*)
        function isFile(const path : string) : boolean;

        (*!------------------------------------------------
         * get directory
         *-----------------------------------------------
         * @param path path to retrieve
         * @return instance of directory
         *-----------------------------------------------*)
        function getDir(const path : string) : IDirectory;

        (*!------------------------------------------------
         * test if path is directory
         *-----------------------------------------------
         * @param path directory path to retrieve
         * @return boolean
         *-----------------------------------------------*)
        function isDir(const path : string) : boolean;

        (*!------------------------------------------------
         * move file or directory
         *-----------------------------------------------
         * @param srcPath source path
         * @param dstPath destination path
         *-----------------------------------------------*)
        procedure move(const srcPath : string; const dstPath : string);

        (*!------------------------------------------------
         * delete file or directory
         *-----------------------------------------------
         * @param path file path
         *-----------------------------------------------*)
        procedure delete(const path : string);
    end;

implementation

uses

    sysutils,
    CompositeDirectoryImpl,
    CompositeFileImpl;

    constructor TCompositeStorage.create(const storages : array of IStorage);
    var i : integer;
    begin
        setlength(fStorages, Length(storages));
        for i := low(storages) to high(storages) do
        begin
            fStorages[i] := storages[i];
        end;
    end;

    destructor TCompositeStorage.destroy();
    var i : integer;
    begin
        for i := low(fStorages) to high(fStorages) do
        begin
            fStorages[i] := nil;
        end;
        fStorages := nil;
        inherited destroy();
    end;


    (*!------------------------------------------------
     * test if file or directory exists
     *-----------------------------------------------
     * @param path file path to check
     * @return true if file exists in filePath
     *-----------------------------------------------*)
    function TCompositeStorage.exists(const path : string) : boolean;
    var i : integer;
    begin
        result := false;
        for i:= low(fStorages) to high(fStorages) do
        begin
            if (fStorages[i].exists(path)) then
            begin
                result := true;
                break;
            end;
        end;
    end;

    (*!------------------------------------------------
     * get file
     *-----------------------------------------------
     * @param filePath file path to retrieve
     * @return instance of file
     *-----------------------------------------------*)
    function TCompositeStorage.getFile(const path : string) : IFile;
    var fileArr : IFileArray;
        i : integer;
    begin
        setLength(fileArr, length(fStorages));
        for i:= low(fStorages) to high(fStorages) do
        begin
            fileArr[i] := fStorages[i].getFile(path);
        end;
        result := TCompositeFile.create(fileArr);
    end;

    (*!------------------------------------------------
     * test if path is file
     *-----------------------------------------------
     * @param path file path to retrieve
     * @return boolean
     *-----------------------------------------------*)
    function TCompositeStorage.isFile(const path : string) : boolean;
    var i : integer;
    begin
        result := false;
        for i:= low(fStorages) to high(fStorages) do
        begin
            if (fStorages[i].isFile(path)) then
            begin
                result := true;
                break;
            end;
        end;
    end;

    (*!------------------------------------------------
     * get directory
     *-----------------------------------------------
     * @param path path to retrieve
     * @return instance of directory
     *-----------------------------------------------*)
    function TCompositeStorage.getDir(const path : string) : IDirectory;
    var dirArr : IDirectoryArray;
        i : integer;
    begin
        setLength(dirArr, length(fStorages));
        for i:= low(fStorages) to high(fStorages) do
        begin
            dirArr[i] := fStorages[i].getDir(path);
        end;
        result := TCompositeDirectory.create(dirArr);
    end;

    (*!------------------------------------------------
     * test if path is directory
     *-----------------------------------------------
     * @param path directory path to retrieve
     * @return boolean
     *-----------------------------------------------*)
    function TCompositeStorage.isDir(const path : string) : boolean;
    var i : integer;
    begin
        result := false;
        for i:= low(fStorages) to high(fStorages) do
        begin
            if (fStorages[i].isDir(path)) then
            begin
                result := true;
                break;
            end;
        end;
    end;

    (*!------------------------------------------------
     * move file or directory
     *-----------------------------------------------
     * @param srcPath source path
     * @param dstPath destination path
     *-----------------------------------------------*)
    procedure TCompositeStorage.move(const srcPath : string; const dstPath : string);
    var i : integer;
    begin
        for i:= low(fStorages) to high(fStorages) do
        begin
            fStorages[i].move(srcPath, dstPath);
        end;
    end;

    (*!------------------------------------------------
     * delete file or directory
     *-----------------------------------------------*)
    procedure TCompositeStorage.delete(const path : string);
    var i : integer;
    begin
        for i:= low(fStorages) to high(fStorages) do
        begin
            fStorages[i].delete(path);
        end;
    end;
end.

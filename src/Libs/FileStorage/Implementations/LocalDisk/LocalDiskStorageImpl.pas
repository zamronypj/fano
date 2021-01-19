{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2021 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit LocalDiskStorageImpl;

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
    TLocalDiskStorage = class (TInjectableObject, IStorage)
    private
        fBaseDir : string;

        function getAbsolutePath(const path : string) : string;
    public
        constructor create(const baseDir : string);

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
    LocalDiskDirectoryImpl,
    LocalDiskFileImpl;

    constructor TLocalDiskStorage.create(const baseDir : string);
    begin
        fBaseDir := baseDir;
    end;

    destructor TLocalDiskStorage.destroy();
    begin
        inherited destroy();
    end;

    function TLocalDiskStorage.getAbsolutePath(const path : string) : string;
    begin
        result := fBaseDir + path;
    end;

    (*!------------------------------------------------
     * test if file or directory exists
     *-----------------------------------------------
     * @param path file path to check
     * @return true if file exists in filePath
     *-----------------------------------------------*)
    function TLocalDiskStorage.exists(const path : string) : boolean;
    begin
        result := FileExists(getAbsolutePath(path));
        if (not result) then
        begin
            //if not found, try if path is directory. on Windows if path
            //is directory, FileExists() returns false while Unix/Linux returns true
            result := DirectoryExists(getAbsolutePath(path));
        end;
    end;

    (*!------------------------------------------------
     * get file
     *-----------------------------------------------
     * @param filePath file path to retrieve
     * @return instance of file
     *-----------------------------------------------*)
    function TLocalDiskStorage.getFile(const path : string) : IFile;
    begin
        result := TLocalDiskFile.create(getAbsolutePath(path));
    end;

    (*!------------------------------------------------
     * test if path is file
     *-----------------------------------------------
     * @param path file path to retrieve
     * @return boolean
     *-----------------------------------------------*)
    function TLocalDiskStorage.isFile(const path : string) : boolean;
    begin
        result := ((FileGetAttr(getAbsolutePath(path)) and faDirectory) = 0);
    end;

    (*!------------------------------------------------
     * get directory
     *-----------------------------------------------
     * @param path path to retrieve
     * @return instance of directory
     *-----------------------------------------------*)
    function TLocalDiskStorage.getDir(const path : string) : IDirectory;
    begin
        result := TLocalDiskDirectory.create(getAbsolutePath(path));
    end;

    (*!------------------------------------------------
     * test if path is directory
     *-----------------------------------------------
     * @param path directory path to retrieve
     * @return boolean
     *-----------------------------------------------*)
    function TLocalDiskStorage.isDir(const path : string) : boolean;
    begin
        result := ((FileGetAttr(getAbsolutePath(path)) and faDirectory) <> 0);
    end;

    (*!------------------------------------------------
     * move file or directory
     *-----------------------------------------------
     * @param srcPath source path
     * @param dstPath destination path
     *-----------------------------------------------*)
    procedure TLocalDiskStorage.move(const srcPath : string; const dstPath : string);
    begin
        RenameFile(srcPath, dstPath);
    end;

    (*!------------------------------------------------
     * delete file or directory
     *-----------------------------------------------*)
    procedure TLocalDiskStorage.delete(const path : string);
    begin
        if isDir(path) then
        begin
            RemoveDir(getAbsolutePath(path));
        end else
        begin
            DeleteFile(getAbsolutePath(path));
        end;
    end;
end.

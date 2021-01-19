{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2020 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit StorageIntf;

interface

{$MODE OBJFPC}
{$H+}

uses

    FileIntf,
    DirectoryIntf;

type

    (*!------------------------------------------------
     * interface for any class having capability to manage
     * storage
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IStorage = interface
        ['{3C7C8998-6507-4B4E-A667-972527B61082}']

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

    IStorageArray = array of IStorage;

implementation

end.

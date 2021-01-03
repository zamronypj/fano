{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2020 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit LocalDiskDirectoryImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    FileIntf,
    DirectoryIntf;

type

    (*!------------------------------------------------
     * class having capability to read and get stats of
     * directory in local disk
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TLocalDiskDirectory = class (TInterfacedObject, IDirectory)
    private
        fDirPath : string;
    public

        constructor create(const dirPath : string);
        destructor destroy(); override;

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

    LocalDiskFileImpl;

    constructor TLocalDiskDirectory.create(const dirPath : string);
    begin
        fDirPath := dirPath;
    end;

    destructor TLocalDiskDirectory.destroy();
    begin
        inherited destroy();
    end;

    (*!------------------------------------------------
     * list content of directory
     *-----------------------------------------------
     * @param filterCriteria filter criteria
     * @return content of file
     *-----------------------------------------------*)
    function TLocalDiskDirectory.list(const filterCriteria : string) : IFileArray;
    var resSearch : TSearchRec;
        totFile : integer;
    begin
        result := nil;
        if FindFirst(filterCriteria, faArchive, resSearch) = 0 then
        begin
            totFile = 0;
            SetLength(result, 50);
            repeat
                //only process file and not . or ..
                if ((resSearch.attr and faArchive) = faArchive) and
                    ((resSearch.name <> '.') or (resSearch.name <> '..')) then
                begin
                    result[totFile - 1] := TLocalDiskFile.create(resSearch.name);
                    inc(totFile);
                    if (totFile > length(result)) then
                    begin
                        setLength(result, totFile + 50);
                    end;
                end;
            until FindNext(resSearch) <> 0;
            FindClose(resSearch);
            SetLength(result, totFile);
        end;
    end;
end.

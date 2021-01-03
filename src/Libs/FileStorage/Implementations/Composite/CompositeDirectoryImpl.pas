{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2020 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit CompositeDirectoryImpl;

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
    TCompositeDirectory = class (TInterfacedObject, IDirectory)
    private
        fDirs : IDirectoryArray;
    public

        constructor create(const dirs : IDirectoryArray);
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


    constructor TCompositeDirectory.create(const dirs : IDirectory);
    var i : integer;
    begin
        setlength(fDirs, Length(dirs));
        for i := low(dirs) to high(dirs) do
        begin
            fDirs[i] := dirs[i];
        end;
    end;

    destructor TCompositeDirectory.destroy();
    var i : integer;
    begin
        for i := low(fDirs) to high(fDirs) do
        begin
            fDirs[i] := nil;
        end;
        fDirs := nil;
        inherited destroy();
    end;

    (*!------------------------------------------------
     * list content of directory
     *-----------------------------------------------
     * @param filterCriteria filter criteria
     * @return content of file
     *-----------------------------------------------*)
    function TCompositeDirectory.list(const filterCriteria : string) : IFileArray;
    begin
        result := nil;
        if (length(fFiles) > 0) then
        begin
            result := fFiles[0].list();
        end;
    end;
end.

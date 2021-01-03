{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2020 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit DirectoryIntf;

interface

{$MODE OBJFPC}
{$H+}

uses

    FileIntf;

type

    (*!------------------------------------------------
     * interface for any class having capability to
     * read and get stats of directory
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IDirectory = interface
        ['{4C24D9A8-0E1C-4DD1-AA02-903B6FEDB116}']

        (*!------------------------------------------------
         * list content of directory
         *-----------------------------------------------
         * @param filterCriteria filter criteria
         * @return content of file
         *-----------------------------------------------*)
        function list(const filterCriteria : string) : IFileArray;

    end;

    IDirectoryArray = array of IDirectory;

implementation

end.

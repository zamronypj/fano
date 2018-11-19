{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ModelReadOnlyDataIntf;

interface

{$MODE OBJFPC}
{$H+}

type

    (*!------------------------------------------------
     * interface that store model data
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IModelReadOnlyData = interface
        ['{DCC3EA21-DC74-46A2-BF54-54621B736E49}']

        (*!------------------------------------------------
         * get total data
         *-----------------------------------------------
         * @return total data
         *-----------------------------------------------*)
        function count() : int64;

        (*!------------------------------------------------
         * move data pointer to next record
         *-----------------------------------------------
         * @return true if successful, false if no more record
         *-----------------------------------------------*)
        function next() : boolean;

        (*!------------------------------------------------
         * read data from current active record by its name
         *-----------------------------------------------
         * @return value in record
         *-----------------------------------------------*)
        function readString(const key : string) : string;
    end;

implementation

end.

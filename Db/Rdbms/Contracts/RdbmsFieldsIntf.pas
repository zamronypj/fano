{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit RdbmsIntf;

interface

{$MODE OBJFPC}
{$H+}


type

    (*!------------------------------------------------
     * interface for any class having capability to
     * handle fields of a result set
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    IRdbmsFields = interface
        ['{7D1D75DB-8F12-4FF8-9235-62E268172693}']

        (*!------------------------------------------------
         * number of fields
         *-------------------------------------------------
         * @return integer number of fields
         *-------------------------------------------------*)
        function count() : integer;

        (*!------------------------------------------------
         * get field by name
         *-------------------------------------------------
         * @return field
         *-------------------------------------------------*)
        function fieldByName(const name : shortstring) : IRdbmsField;

        (*!------------------------------------------------
         * get field by name
         *-------------------------------------------------
         * @return field
         *-------------------------------------------------*)
        function fieldByIndex(const indx : integer) : IRdbmsField;
    end;

implementation

end.

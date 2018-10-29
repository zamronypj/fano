{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit DbConnectionIntf;

interface

{$MODE OBJFPC}
{$H+}

type

    (*!------------------------------------------------
     * interface for any class having capability to
     * handle database operation
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    IDatabaseConnection = interface
        ['{6DC31676-A7CD-4798-B953-0188421C512B}']

        (*!------------------------------------------------
         * send query to database
         *-------------------------------------------------
         * @param sql
         * @return database result
         *-------------------------------------------------*)
        function query(const sql : string) : IDatabaseResult;
    end;

implementation

end.

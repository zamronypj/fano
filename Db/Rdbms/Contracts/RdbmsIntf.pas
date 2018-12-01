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

uses

    RdbmsResultSetIntf,
    RdbmsStatementIntf;

type

    (*!------------------------------------------------
     * interface for any class having capability to
     * handle relational database operation
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    IRdbms = interface
        ['{996106E4-C199-4605-A372-12B721D44E27}']

        (*!------------------------------------------------
         * create connection to RDBMS server
         *-------------------------------------------------
         * @param host hostname/ip where RDBMS server run
         * @param dbname database name to use
         * @param username user name credential to login
         * @param password password credential to login
         * @param port TCP port where RDBMS listen
         * @return current instance
         *-------------------------------------------------*)
        function connect(
            const host : string;
            const dbname : string;
            const username : string;
            const password : string;
            const port : word
        ) : IRdbms;

        (*!------------------------------------------------
         * initiate a transaction
         *-------------------------------------------------
         * @return database connection instance
         *-------------------------------------------------*)
        function beginTransaction() : IRdbms;

        (*!------------------------------------------------
         * end a transaction
         *-------------------------------------------------
         * @return database connection instance
         *-------------------------------------------------
         * This is provided to make it easy to auto commit or
         * rollback
         *-------------------------------------------------*)
        function endTransaction() : IRdbms;

        (*!------------------------------------------------
         * created prepared sql statement
         *-------------------------------------------------
         * @return result set
         *-------------------------------------------------*)
        function prepare(const sql : string) : IRdbmsStatement;
    end;

implementation

end.

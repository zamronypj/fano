{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit DbIntf;

interface

{$MODE OBJFPC}
{$H+}

uses

    DbConnectionIntf;

type

    (*!------------------------------------------------
     * interface for any class having capability to
     * handle database operation
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    IDatabase = interface
        ['{DCA13263-5A97-40F5-A9F3-EAC897457DCC}']

        (*!------------------------------------------------
         * create connection to database server
         *-------------------------------------------------
         * @param connectionString
         * @return database connection instance
         *-------------------------------------------------*)
        function connect(const connectionString : string) : IDatabaseConnection;
    end;

implementation

end.

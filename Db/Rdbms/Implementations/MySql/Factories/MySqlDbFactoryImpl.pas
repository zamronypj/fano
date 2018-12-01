{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit MySqlDbFactoryImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl;

type

    (*!------------------------------------------------
     * basic class having capability to
     * handle mysql relational database operation
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TMySqlDbFactory = class(TFactory)
    private
        mysqlVersion : string;
        databaseHostname : string;
        databaseName : string;
        databaseUsername : string;
        databasePassword : string;
        databasePort : word;
    public

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
        constructor create(
            const version : string;
            const host : string;
            const dbname : string;
            const username : string;
            const password : string;
            const port : word = 3306
        );

        (*!---------------------------------------------------
         * build class instance
         *----------------------------------------------------
         * @param container dependency container instance
         *---------------------------------------------------*)
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses

    RdbmsIntf,
    MySqlDbImpl;

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
    constructor TMySqlDbFactory.create(
        const version : string;
        const host : string;
        const dbname : string;
        const username : string;
        const password : string;
        const port : word = 3306
    );
    begin
        mysqlVersion := version;
        databaseHostname := host;
        databaseName := dbname;
        databaseUsername := username;
        databasePassword := password;
        databasePort := port;
    end;


    (*!---------------------------------------------------
     * build class instance
     *----------------------------------------------------
     * @param container dependency container instance
     *---------------------------------------------------*)
    function TMySqlDbFactory.build(const container : IDependencyContainer) : IDependency;
    var db : IRdbms;
    begin
        db := TMySqlDb.create(mysqlVersion);
        db.connect(
            databaseHostname,
            databaseName,
            databaseUsername,
            databasePassword,
            databasePort
        );
        result := db as IDependency;
    end;

end.

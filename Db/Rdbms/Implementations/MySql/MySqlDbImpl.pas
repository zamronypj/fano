{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit MySqlDbImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    DependencyIntf,
    RdbmsIntf,
    db,
    sqldb,
    mysql56conn;

type

    (*!------------------------------------------------
     * basic class having capability to
     * handle mysql relational database operation
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TMySQLDb = class(TInterfacedObject, IRdbms, IRdbmsResultSet, IRdbmsFields, IRdbmsField, IDependency)
    private
        dbInstance : TSQLConnector;
        query : TSQLQuery;
        currentField : TField;
    public
        constructor create();
        destructor destroy(); override;

        (*!------------------------------------------------
         * create connection to database server
         *-------------------------------------------------
         * @param host hostname/ip where MySQl server run
         * @param dbname database name to use
         * @param username user name credential to login
         * @param password password credential to login
         * @param port TCP port where MySQL listen
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
         * @param connectionString
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
    end;

implementation

uses

    EInvalidDbConnectionImpl,
    EInvalidDbFieldImpl;

resourcestring

    sErrInvalidConnection = 'Invalid connection';
    sErrInvalidField = 'Invalid field.';

    constructor TMySQLDb.create();
    begin
        dbInstance := nil;
        query := nil;
        currentField := nil;
    end;

    destructor TMySQLDb.destroy();
    begin
        inherited destroy();
        query.free();
        dbInstance.free();
        currentField := nil;
    end;

    (*!------------------------------------------------
     * create connection to database server
     *-------------------------------------------------
     * @param host hostname/ip where MySQl server run
     * @param dbname database name to use
     * @param username user name credential to login
     * @param password password credential to login
     * @param port TCP port where MySQL listen
     * @return current instance
     *-------------------------------------------------*)
    function TMySQLDb.connect(
        const host : string;
        const dbname : string;
        const username : string;
        const password : string;
        const port : word
    ) : IRdbms;
    begin
        if (dbInstance = nil) then
        begin
            dbInstance := TSQLConnector.create(nil);
            dbInstance.transaction := TSQLTransaction.create(dbInstance);
            query := TSQLQuery.create(nil);
            query.database := dbInstance;
        end;
        dbInstance.ConnectorType := 'mysql 5.6';
        dbInstance.HostName := host;
        dbInstance.DatabaseName := dbname;
        dbInstance.UserName := username;
        dbInstance.Password := password;
    end;

    (*!------------------------------------------------
     * initiate a transaction
     *-------------------------------------------------
     * @param connectionString
     * @return database connection instance
     *-------------------------------------------------*)
    function TMySQLDb.beginTransaction() : IRdbms;
    begin
        if (dbInstance = nil) then
        begin
            raise EInvalidDbConnection.create(sErrInvalidConnection);
        end;
        dbInstance.startTransaction();
    end;

    (*!------------------------------------------------
     * commit or rollback and end a transaction
     *-------------------------------------------------
     * @return database connection instance
     *-------------------------------------------------*)
    function TMySQLDb.endTransaction() : IRdbms;
    begin
        if (dbInstance = nil) then
        begin
            raise EInvalidDbConnection.create(sErrInvalidConnection);
        end;
        dbInstance.endTransaction();
    end;

    (*!------------------------------------------------
     * execute query
     *-------------------------------------------------
     * @return result set
     *-------------------------------------------------*)
    function TMySQLDb.exec(const sql : string) : IRdbmsResultSet;
    begin
        query.sql := sql;
        query.open();
        result := self;
    end;

    (*!------------------------------------------------
     * test if we in end of result set
     *-------------------------------------------------
     * @return true if at end of file and no more record
     *-------------------------------------------------*)
    function TMySQLDb.eof() : boolean;
    begin
        result := query.eof;
    end;

    (*!------------------------------------------------
     * advanced cursor position to next record
     *-------------------------------------------------
     * @return true if at end of file and no more record
     *-------------------------------------------------*)
    function TMySQLDb.next() : IRdbmsResultSet;
    begin
        query.next();
        result := self;
    end;

    (*!------------------------------------------------
     * advanced cursor position to next record
     *-------------------------------------------------
     * @return true if at end of file and no more record
     *-------------------------------------------------*)
    function TMySQLDb.fields() : IRdbmsFields;
    begin
        result := self;
    end;

    (*!------------------------------------------------
     * number of fields
     *-------------------------------------------------
     * @return integer number of fields
     *-------------------------------------------------*)
    function TMySQLDb.count() : integer;
    begin
        result := query.fields.count;
    end;

    (*!------------------------------------------------
     * get field by name
     *-------------------------------------------------
     * @return field
     *-------------------------------------------------*)
    function TMySQLDb.fieldByName(const name : shortstring) : IRdbmsField;
    begin
        currentField := query.fields.fieldByName(name);
        result := self;
    end;

    (*!------------------------------------------------
     * get field by name
     *-------------------------------------------------
     * @return field
     *-------------------------------------------------*)
    function TMySQLDb.fieldByIndex(const indx : integer) : IRdbmsField;
    begin
        currentField := query.fields.fieldByNumber(name);
        result := self;
    end;

    (*!------------------------------------------------
     * return field data as boolean
     *-------------------------------------------------
     * @return boolean value of field
     *-------------------------------------------------*)
    function TMySQLDb.asBoolean() : boolean;
    begin
        if (currentField = nil) then
        begin
            raise EInvalidDbField.create(sErrInvalidField);
        end;
        result := currentField.asBoolean;
    end;

    (*!------------------------------------------------
     * return field data as integer value
     *-------------------------------------------------
     * @return value of field
     *-------------------------------------------------*)
    function TMySQLDb.asInteger() : integer;
    begin
        if (currentField = nil) then
        begin
            raise EInvalidDbField.create(sErrInvalidField);
        end;
        result := currentField.asInteger;
    end;

    (*!------------------------------------------------
     * return field data as string value
     *-------------------------------------------------
     * @return value of field
     *-------------------------------------------------*)
    function TMySQLDb.asString() : string;
    begin
        if (currentField = nil) then
        begin
            raise EInvalidDbField.create(sErrInvalidField);
        end;
        result := currentField.asString;
    end;

    (*!------------------------------------------------
     * return field data as double value
     *-------------------------------------------------
     * @return value of field
     *-------------------------------------------------*)
    function TMySQLDb.asFloat() : double;
    begin
        if (currentField = nil) then
        begin
            raise EInvalidDbField.create(sErrInvalidField);
        end;
        result := currentField.asFloat;
    end;

    (*!------------------------------------------------
     * return field data as datetime value
     *-------------------------------------------------
     * @return value of field
     *-------------------------------------------------*)
    function TMySQLDb.asDateTime() : TDateTime;
    begin
        if (currentField = nil) then
        begin
            raise EInvalidDbField.create(sErrInvalidField);
        end;
        result := currentField.asDateTime;
    end;
end.

{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit RdbmsImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    RdbmsIntf,
    RdbmsResultSetIntf,
    RdbmsFieldsIntf,
    RdbmsFieldIntf,
    db,
    sqldb,
    InjectableObjectImpl;

type

    (*!------------------------------------------------
     * basic class having capability to
     * handle relational database operation
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TRdbms = class(TInjectableObject, IRdbms, IRdbmsResultSet, IRdbmsFields, IRdbmsField)
    private
        dbInstance : TSQLConnector;
        query : TSQLQuery;
        currentField : TField;
        connectionType : string;
    public
        constructor create(const connType : string);
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

        (*!------------------------------------------------
         * execute query
         *-------------------------------------------------
         * @return result set
         *-------------------------------------------------*)
        function exec(const sql : string) : IRdbmsResultSet;

          (*!------------------------------------------------
           * total data in result set
           *-------------------------------------------------
           * @return total data in current result set
           *-------------------------------------------------*)
          function resultCount() : largeInt;

          (*!------------------------------------------------
           * test if we in end of result set
           *-------------------------------------------------
           * @return true if at end of file and no more record
           *-------------------------------------------------*)
          function eof() : boolean;

          (*!------------------------------------------------
           * advanced cursor position to next record
           *-------------------------------------------------
           * @return true if at end of file and no more record
           *-------------------------------------------------*)
          function next() : IRdbmsResultSet;

          (*!------------------------------------------------
           * get list of fields
           *-------------------------------------------------
           * @return current fields
           *-------------------------------------------------*)
          function fields() : IRdbmsFields;

          (*!------------------------------------------------
           * number of fields
           *-------------------------------------------------
           * @return integer number of fields
           *-------------------------------------------------*)
          function fieldCount() : integer;

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

          (*!------------------------------------------------
           * return field data as boolean
           *-------------------------------------------------
           * @return boolean value of field
           *-------------------------------------------------*)
          function asBoolean() : boolean;

          (*!------------------------------------------------
           * return field data as integer value
           *-------------------------------------------------
           * @return value of field
           *-------------------------------------------------*)
          function asInteger() : integer;

          (*!------------------------------------------------
           * return field data as string value
           *-------------------------------------------------
           * @return value of field
           *-------------------------------------------------*)
          function asString() : string;

          (*!------------------------------------------------
           * return field data as double value
           *-------------------------------------------------
           * @return value of field
           *-------------------------------------------------*)
          function asFloat() : double;

          (*!------------------------------------------------
           * return field data as datetime value
           *-------------------------------------------------
           * @return value of field
           *-------------------------------------------------*)
          function asDateTime() : TDateTime;
    end;

implementation

uses

    EInvalidDbConnectionImpl,
    EInvalidDbFieldImpl;

resourcestring

    sErrInvalidConnection = 'Invalid connection';
    sErrInvalidField = 'Invalid field.';

    constructor TRdbms.create(const connType : string);
    begin
        dbInstance := nil;
        query := nil;
        currentField := nil;
        connectionType := connType;
    end;

    destructor TRdbms.destroy();
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
    function TRdbms.connect(
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
        dbInstance.ConnectorType := connectionType;
        dbInstance.HostName := host;
        dbInstance.DatabaseName := dbname;
        dbInstance.UserName := username;
        dbInstance.Password := password;
        result := self;
    end;

    (*!------------------------------------------------
     * initiate a transaction
     *-------------------------------------------------
     * @param connectionString
     * @return database connection instance
     *-------------------------------------------------*)
    function TRdbms.beginTransaction() : IRdbms;
    begin
        if (dbInstance = nil) then
        begin
            raise EInvalidDbConnection.create(sErrInvalidConnection);
        end;
        dbInstance.startTransaction();
        result := self;
    end;

    (*!------------------------------------------------
     * commit or rollback and end a transaction
     *-------------------------------------------------
     * @return database connection instance
     *-------------------------------------------------*)
    function TRdbms.endTransaction() : IRdbms;
    begin
        if (dbInstance = nil) then
        begin
            raise EInvalidDbConnection.create(sErrInvalidConnection);
        end;
        dbInstance.endTransaction();
        result := self;
    end;

    (*!------------------------------------------------
     * execute query
     *-------------------------------------------------
     * @return result set
     *-------------------------------------------------*)
    function TRdbms.exec(const sql : string) : IRdbmsResultSet;
    begin
        query.sql.text := sql;
        query.open();
        result := self;
    end;

    (*!------------------------------------------------
     * number of record in result set
     *-------------------------------------------------
     * @return largeInt number of records
     *-------------------------------------------------*)
    function TRdbms.resultCount() : largeInt;
    begin
        result := query.RecordCount;
    end;

    (*!------------------------------------------------
     * test if we in end of result set
     *-------------------------------------------------
     * @return true if at end of file and no more record
     *-------------------------------------------------*)
    function TRdbms.eof() : boolean;
    begin
        result := query.eof;
    end;

    (*!------------------------------------------------
     * advanced cursor position to next record
     *-------------------------------------------------
     * @return true if at end of file and no more record
     *-------------------------------------------------*)
    function TRdbms.next() : IRdbmsResultSet;
    begin
        query.next();
        result := self;
    end;

    (*!------------------------------------------------
     * advanced cursor position to next record
     *-------------------------------------------------
     * @return true if at end of file and no more record
     *-------------------------------------------------*)
    function TRdbms.fields() : IRdbmsFields;
    begin
        result := self;
    end;

    (*!------------------------------------------------
     * number of fields
     *-------------------------------------------------
     * @return integer number of fields
     *-------------------------------------------------*)
    function TRdbms.fieldCount() : integer;
    begin
        result := query.fields.count;
    end;

    (*!------------------------------------------------
     * get field by name
     *-------------------------------------------------
     * @return field
     *-------------------------------------------------*)
    function TRdbms.fieldByName(const name : shortstring) : IRdbmsField;
    begin
        currentField := query.fields.fieldByName(name);
        result := self;
    end;

    (*!------------------------------------------------
     * get field by name
     *-------------------------------------------------
     * @return field
     *-------------------------------------------------*)
    function TRdbms.fieldByIndex(const indx : integer) : IRdbmsField;
    begin
        currentField := query.fields.fieldByNumber(indx);
        result := self;
    end;

    (*!------------------------------------------------
     * return field data as boolean
     *-------------------------------------------------
     * @return boolean value of field
     *-------------------------------------------------*)
    function TRdbms.asBoolean() : boolean;
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
    function TRdbms.asInteger() : integer;
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
    function TRdbms.asString() : string;
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
    function TRdbms.asFloat() : double;
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
    function TRdbms.asDateTime() : TDateTime;
    begin
        if (currentField = nil) then
        begin
            raise EInvalidDbField.create(sErrInvalidField);
        end;
        result := currentField.asDateTime;
    end;
end.

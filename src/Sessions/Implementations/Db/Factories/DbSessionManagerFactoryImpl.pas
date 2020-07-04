{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2020 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit DbSessionManagerFactoryImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl,
    SessionConsts,
    RdbmsIntf,
    SessionIdGeneratorIntf;

type
    (*!------------------------------------------------
     * TDbSessionManager factory class
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TDbSessionManagerFactory = class abstract (TFactory)
    protected
        fCookieName : string;
        fSessionIdGenerator : ISessionIdGenerator;
        fRdbms : IRdbms;
        fTableName : string;
        fSessionIdColumn : string;
        fDataColumn : string;
        fExpiredAtColumn : string;
    public
        constructor create(const cookieName : string = FANO_COOKIE_NAME);

        function sessionIdGenerator(const sessIdGen : ISessionIdGenerator) : TDbSessionManagerFactory;
        function rdbms(const ardbms : IRdbms) : TDbSessionManagerFactory;

        function table(const tableName : string) : TDbSessionManagerFactory;
        function sessionIdColumn(const sessionIdName : string) : TDbSessionManagerFactory;
        function dataColumn(const dataName : string) : TDbSessionManagerFactory;
        function expiredAtColumn(const expiredAtName : string) : TDbSessionManagerFactory;
    end;

implementation

    constructor TDbSessionManagerFactory.create(const cookieName : string = FANO_COOKIE_NAME);
    begin
        fCookieName := cookieName;
    end;

    function TDbSessionManagerFactory.sessionIdGenerator(const sessIdGen : ISessionIdGenerator) : TDbSessionManagerFactory;
    begin
        fSessionIdGenerator := sessIdGen;
        result := self;
    end;

    function TDbSessionManagerFactory.rdbms(const ardbms : IRdbms) : TDbSessionManagerFactory;
    begin
        fRdbms := ardbms;
        result := self;
    end;

    function TDbSessionManagerFactory.table(const tableName : string) : TDbSessionManagerFactory;
    begin
        fTableName := tableName;
        result := self;
    end;

    function TDbSessionManagerFactory.sessionIdColumn(const sessionIdName : string) : TDbSessionManagerFactory;
    begin
        fSessionIdColumn := sessionIdName;
        result := self;
    end;

    function TDbSessionManagerFactory.dataColumn(const dataName : string) : TDbSessionManagerFactory;
    begin
        fDataColumn := dataName;
        result := self;
    end;

    function TDbSessionManagerFactory.expiredAtColumn(const expiredAtName : string) : TDbSessionManagerFactory;
    begin
        fExpiredAtColumn := expiredAtName;
        result := self;
    end;
end.

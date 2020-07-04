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
    RdbmsFactoryIntf,
    SessionIdGeneratorFactoryIntf,
    AbstractSessionManagerFactoryImpl;

type
    (*!------------------------------------------------
     * TDbSessionManager factory class
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TDbSessionManagerFactory = class abstract (TAbstractSessionManagerFactory)
    protected
        fRdbmsFactory : IRdbmsFactory;
        fTableName : string;
        fSessionIdColumn : string;
        fDataColumn : string;
        fExpiredAtColumn : string;
    public
        function rdbms(const rdbmsFactory : IRdbmsFactory) : TDbSessionManagerFactory;

        function table(const tableName : string) : TDbSessionManagerFactory;
        function sessionIdColumn(const sessionIdName : string) : TDbSessionManagerFactory;
        function dataColumn(const dataName : string) : TDbSessionManagerFactory;
        function expiredAtColumn(const expiredAtName : string) : TDbSessionManagerFactory;
    end;

implementation

    function TDbSessionManagerFactory.rdbms(const rdbmsFactory : IRdbmsFactory) : TDbSessionManagerFactory;
    begin
        fRdbmsFactory := rdbmsFactory;
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

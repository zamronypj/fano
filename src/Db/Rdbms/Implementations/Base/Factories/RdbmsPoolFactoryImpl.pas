{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit RdbmsPoolFactoryImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    DependencyIntf,
    DependencyContainerIntf,
    RdbmsPoolIntf,
    RdbmsFactoryIntf,
    FactoryImpl;


type

    (*!------------------------------------------------
     * Factory class for TRdbmsPool class
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TRdbmsPoolFactory = class(TFactory)
    private
        fDbFactory : IRdbmsFactory;
        fPoolSize : integer;
    public

        (*!------------------------------------------------
         * create connection to RDBMS server
         *-------------------------------------------------
         * @param host hostname/ip where RDBMS server run
         * @param dbname database name to use
         * @param username user name credential to login
         * @param password password credential to login
         * @param port TCP port where RDBMS listen
         *-------------------------------------------------*)
        constructor create(
            const rdbmsFactory : IRdbmsFactory;
            const poolSize : integer
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

    RdbmsPoolImpl;

    (*!------------------------------------------------
     * create connection to RDBMS server
     *-------------------------------------------------
     * @param host hostname/ip where RDBMS server run
     * @param dbname database name to use
     * @param username user name credential to login
     * @param password password credential to login
     * @param port TCP port where RDBMS listen
     *-------------------------------------------------*)
    constructor TRdbmsPoolFactory.create(
        const rdbmsFactory : IRdbmsFactory;
        const poolSize : integer
    );
    begin
        fDbFactory := rdbmsFactory;
        fPoolSize := poolSize;
    end;

    (*!---------------------------------------------------
     * build class instance
     *----------------------------------------------------
     * @param container dependency container instance
     *---------------------------------------------------*)
    function TRdbmsPoolFactory.build(const container : IDependencyContainer) : IDependency; override;
    begin
        result := TRdmbsPool.create(fDbFactory, fPoolSize) as IDependency;
    end;

end.

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
    TMySQLDbFactory = class(TFactory)
    public
        (*!---------------------------------------------------
         * build class instance
         *----------------------------------------------------
         * @param container dependency container instance
         *---------------------------------------------------*)
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses

    MySqlDbImpl;

    (*!---------------------------------------------------
     * build class instance
     *----------------------------------------------------
     * @param container dependency container instance
     *---------------------------------------------------*)
    function TMySQLDbFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TMySQLDb.create();
    end;

end.

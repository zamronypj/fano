{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit EnvironmentFactoryImpl;

interface

{$MODE OBJFPC}

uses

    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl;

type
    (*!------------------------------------------------
     * factory class to create class having capability
     * to retrieve CGI environment variable
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *--------------------------------------------------*)
    TCGIEnvironmentFactory = class(TFactory, IDependencyFactory)
    public
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses

    EnvironmentImpl;

    function TCGIEnvironmentFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TCGIEnvironment.create();
    end;

end.

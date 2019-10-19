{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit UwsgiEnvironmentFactoryImpl;

interface

{$MODE OBJFPC}

uses

    DependencyIntf,
    DependencyContainerIntf,
    StreamAdapterIntf,
    EnvironmentIntf,
    EnvironmentFactoryIntf,
    FactoryImpl;

type
    (*!------------------------------------------------
     * factory class to create class having capability
     * to retrieve environment variable from uwsgi data
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *--------------------------------------------------*)
    TUwsgiEnvironmentFactory = class(TFactory, IDependencyFactory, ICGIEnvironmentFactory)
    private
        fParamStr : string;
    public
        constructor create(const paramStr : string);
        function build(const container : IDependencyContainer) : IDependency; override;
        function build() : ICGIEnvironment;
    end;

implementation

uses

    classes,
    UwsgiParamKeyValuePairImpl,
    KeyValueEnvironmentImpl;

    constructor TUwsgiEnvironmentFactory.create(const paramStr : string);
    begin
        fParamStr := paramStr;
    end;

    function TUwsgiEnvironmentFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := build() as IDependency;
    end;

    function TUwsgiEnvironmentFactory.build() : ICGIEnvironment;
    begin
        result := TKeyValueEnvironment.create(
            TUwsgiParamKeyValuePair.create(fParamStr)
        );
    end;

end.

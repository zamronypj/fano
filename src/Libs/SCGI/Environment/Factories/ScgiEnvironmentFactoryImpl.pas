{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ScgiEnvironmentFactoryImpl;

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
     * to retrieve SCGI environment variable
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *--------------------------------------------------*)
    TSCGIEnvironmentFactory = class(TFactory, IDependencyFactory, ICGIEnvironmentFactory)
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
    ScgiParamKeyValuePairImpl,
    KeyValueEnvironmentImpl;

    constructor TSCGIEnvironmentFactory.create(const paramStr : string);
    begin
        fParamStr := paramStr;
    end;

    function TFCGIEnvironmentFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := build() as IDependency;
    end;

    function TFCGIEnvironmentFactory.build() : ICGIEnvironment;
    begin
        result := TKeyValueEnvironment.create(
            TScgiParamKeyValuePair.create(fParamStr)
        );
    end;

end.

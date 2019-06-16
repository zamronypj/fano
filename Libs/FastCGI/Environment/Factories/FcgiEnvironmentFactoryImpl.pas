{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FcgiEnvironmentFactoryImpl;

interface

{$MODE OBJFPC}

uses

    DependencyIntf,
    DependencyContainerIntf,
    StreamAdapterIntf,
    FactoryImpl;

type
    (*!------------------------------------------------
     * factory class to create class having capability
     * to retrieve FastCGI environment variable
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *--------------------------------------------------*)
    TFCGIEnvironmentFactory = class(TFactory, IDependencyFactory)
    private
        fcgiParamStream : IStreamAdapter;
    public
        constructor create(const paramStream : IStreamAdapter);
        destructor destroy(); override;
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses

    FcgiEnvironmentImpl;

    constructor TFCGIEnvironmentFactory.create(const paramStream : IStreamAdapter);
    begin
        fParamStream := paramStream;
    end;

    destructor TFCGIEnvironmentFactory.destroy();
    begin
        inherited destroy();
        fParamStream := nil;
    end;

    function TFCGIEnvironmentFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TFCGIEnvironment.create(

        );
    end;

end.

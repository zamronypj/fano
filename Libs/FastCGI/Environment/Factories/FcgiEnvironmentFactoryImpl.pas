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
        fParamsRecords : array of IFcgiRecord;
    public
        constructor create(const params : array of IFcgiRecord);
        destructor destroy(); override;
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses

    FcgiEnvironmentImpl;

    constructor TFCGIEnvironmentFactory.create(const params : array of IFcgiRecord);
    begin
        fParamsRecords := params;
    end;

    destructor TFCGIEnvironmentFactory.destroy();
    begin
        inherited destroy();
        setLength(fParamsRecords, 0);
    end;

    function TFCGIEnvironmentFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TFCGIEnvironment.create(

        );
    end;

end.

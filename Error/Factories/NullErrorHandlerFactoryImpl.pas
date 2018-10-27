{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit NullErrorHandlerFactoryImpl;

interface

{$MODE OBJFPC}
{$H+}

uses
    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl;

type

    TNullErrorHandlerFactory = class(TFactory, IDependencyFactory)
    public
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses
    NullErrorHandlerImpl;

    function TNullErrorHandlerFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TNullErrorHandler.create();
    end;

end.

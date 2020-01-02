{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ProdOrDevErrorHandlerFactoryImpl;

interface

{$MODE OBJFPC}

uses

    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl;

type

    (*!------------------------------------------------
     * factory class for error handler for production setup
     * which is to log exception to file and output
     * nicely formatted error page
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TProdOrDevErrorHandlerFactory = class(TFactory, IDependencyFactory)
    private
        templateFilename : string;
        isProdEnv : boolean;
    public
        constructor create(const templateFile : string; const isProd : boolean);
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses

    ErrorHandlerImpl,
    TemplateErrorHandlerImpl,
    ConditionalErrorHandlerImpl;

    constructor TProdOrDevErrorHandlerFactory.create(
        const templateFile : string;
        const isProd : boolean
    );
    begin
        templateFilename := templateFile;
        isProdEnv := isProd;
    end;

    function TProdOrDevErrorHandlerFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TConditionalErrorHandler.create(
            TTemplateErrorHandler.create(templateFilename),
            TErrorHandler.create(),
            isProdEnv
        );
    end;

end.

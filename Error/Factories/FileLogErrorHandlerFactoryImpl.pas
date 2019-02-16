{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FileLogErrorHandlerFactoryImpl;

interface

{$MODE OBJFPC}

uses
    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl;

type

    TFileLogErrorHandlerFactory = class(TFactory, IDependencyFactory)
    private
        logFilename : string;
    public
        constructor create(const filename : string);
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses

    FileLoggerImpl,
    LogErrorHandlerImpl;

    constructor TFileLogErrorHandlerFactory.create(const filename : string);
    begin
        logFilename := filename;
    end;

    function TFileLogErrorHandlerFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TLogErrorHandler.create(TFileLogger.create(logFilename));
    end;

end.

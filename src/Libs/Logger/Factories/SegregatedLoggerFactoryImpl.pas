{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit SegregatedLoggerFactoryImpl;

interface

{$MODE OBJFPC}

uses

    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl;

type
    {------------------------------------------------
     factory class for TSegregatedLogger

     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TSegregatedLoggerFactory = class(TFactory, IDependencyFactory)
    private
        fInfoLoggerFactory : IDependencyFactory;
        fDebugLoggerFactory : IDependencyFactory;
        fWarningLoggerFactory : IDependencyFactory;
        fCriticalLoggerFactory : IDependencyFactory;
    public
        (*!--------------------------------------
         * constructor
         * --------------------------------------
         * @param infoLoggerFactory factory for info log
         * @param debugLoggerFactory factory for debug log
         * @param warningLoggerFactory factory for warning log
         * @param criticalLoggerFactory factory for critical log
         *---------------------------------------*)
        constructor create(
            const infoLoggerFactory : IDependencyFactory;
            const debugLoggerFactory : IDependencyFactory;
            const warningLoggerFactory : IDependencyFactory;
            const criticalLoggerFactory : IDependencyFactory
        );

        destructor destroy(); override;

        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses

    LoggerIntf,
    SegregatedLoggerImpl;

    (*!--------------------------------------
     * constructor
     * --------------------------------------
     * @param infoLoggerFactory factory for info log
     * @param debugLoggerFactory factory for debug log
     * @param warningLoggerFactory factory for warning log
     * @param criticalLoggerFactory factory for critical log
     *---------------------------------------*)
    constructor TSegregatedLoggerFactory.create(
        const infoLoggerFactory : IDependencyFactory;
        const debugLoggerFactory : IDependencyFactory;
        const warningLoggerFactory : IDependencyFactory;
        const criticalLoggerFactory : IDependencyFactory
    );
    begin
        fInfoLoggerFactory := infoLoggerFactory;
        fDebugLoggerFactory := debugLoggerFactory;
        fWarningLoggerFactory := warningLoggerFactory;
        fCriticalLoggerFactory := criticalLoggerFactory;
    end;

    destructor TSegregatedLoggerFactory.destroy();
    begin
        inherited destroy();
        fInfoLoggerFactory := nil;
        fDebugLoggerFactory := nil;
        fWarningLoggerFactory := nil;
        fCriticalLoggerFactory := nil;
    end;

    function TSegregatedLoggerFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TSegregatedLogger.create(
            fInfoLoggerFactory.build(container) as ILogger,
            fDebugLoggerFactory.build(container) as ILogger,
            fWarningLoggerFactory.build(container) as ILogger,
            fCriticalLoggerFactory.build(container) as ILogger
        );
    end;

end.

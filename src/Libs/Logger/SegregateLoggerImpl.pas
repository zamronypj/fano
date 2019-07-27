{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit SegregatedLoggerImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    SerializeableIntf,
    LoggerIntf,
    AbstractLoggerImpl;

type

    (*!------------------------------------------------
     * logger class that segregates each level
     * to dedicated logger. So we can separate,
     * for example, to log INFO type log to separate
     * file than CRITICAL type, or suppress DEBUG level type, etc
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TSegregatedLogger = class(TAbstractLogger)
    private
        infoLogger : ILogger;
        debugLogger : ILogger;
        warningLogger : ILogger;
        criticalLogger : ILogger;
    public

        (*!--------------------------------------
         * constructor
         * --------------------------------------
         * @param infoLoggerInst logger for info log
         * @param debugLoggerInst logger for debug log
         * @param warningLoggerInst logger for warning log
         * @param criticalLoggerInst logger for critical log
         *---------------------------------------*)
        constructor create(
            const infoLoggerInst : ILogger;
            const debugLoggerInst : ILogger;
            const warningLoggerInst : ILogger;
            const criticalLoggerInst : ILogger
        );

        (*!--------------------------------------
         * destructor
         *---------------------------------------*)
        destructor destroy(); override;

        (*!--------------------------------------
         * log message
         * --------------------------------------
         * @param level type of log
         * @param msg log message
         * @param context data related to log message
         *               (if any)
         * @return current instance
         *---------------------------------------*)
        function log(
            const level : string;
            const msg : string;
            const context : ISerializeable = nil
        ) : ILogger; override;
    end;

implementation

    (*!--------------------------------------
     * constructor
     * --------------------------------------
     * @param infoLoggerInst logger for info log
     * @param debugLoggerInst logger for debug log
     * @param warningLoggerInst logger for warning log
     * @param criticalLoggerInst logger for critical log
     *---------------------------------------*)
    constructor TSegregatedLogger.create(
        const infoLoggerInst : ILogger;
        const debugLoggerInst : ILogger;
        const warningLoggerInst : ILogger;
        const criticalLoggerInst : ILogger
    );
    begin
        infoLogger := infoLoggerInst;
        debugLogger := debugLoggerInst;
        warningLogger := warningLoggerInst;
        criticalLogger := criticalLoggerInst;
    end;

    (*!--------------------------------------
     * destructor
     *---------------------------------------*)
    destructor TSegregatedLogger.destroy();
    begin
        inherited destroy();
        infoLogger := nil;
        debugLogger := nil;
        warningLogger := nil;
        criticalLogger := nil;
    end;

    (*!--------------------------------------
     * log message
     * --------------------------------------
     * @param level type of log
     * @param msg log message
     * @param context data related to log message
     *               (if any)
     * @return current instance
     *---------------------------------------*)
    function TSegregatedLogger.log(
        const level : string;
        const msg : string;
        const context : ISerializeable = nil
    ) : ILogger;
    begin
        if (level = 'INFO') then
        begin
            infoLogger.log(level, msg, context);
        end else
        if (level = 'DEBUG') then
        begin
            debugLogger.log(level, msg, context);
        end else
        if (level = 'WARNING') then
        begin
            warningLogger.log(level, msg, context);
        end else
        if (level = 'CRITICAL') then
        begin
            criticalLogger.log(level, msg, context);
        end
        result := self;
    end;

end.

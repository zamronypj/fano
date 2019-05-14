{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit CompositeLoggerImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    SerializeableIntf,
    LoggerIntf,
    AbstractLoggerImpl;

type

    (*!------------------------------------------------
     * logger class that is composed from two other loggers
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TCompositeLogger = class(TAbstractLogger)
    private
        firstLogger : ILogger;
        secondLogger : ILogger;
    public

        (*!--------------------------------------
         * constructor
         * --------------------------------------
         * @param aLogger1 first logger
         * @param aLogger2 second logger
         *---------------------------------------*)
        constructor create(const aLogger1 : ILogger; const aLogger2 : ILogger);

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
     * @param aLogger1 first logger
     * @param aLogger2 second logger
     *---------------------------------------*)
    constructor TCompositeLogger.create(const aLogger1 : ILogger; const aLogger2 : ILogger);
    begin
        firstLogger  := aLogger1;
        secondLogger := aLogger2;
    end;

    (*!--------------------------------------
     * destructor
     *---------------------------------------*)
    destructor TCompositeLogger.destroy();
    begin
        inherited destroy();
        firstLogger := nil;
        secondLogger := nil;
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
    function TCompositeLogger.log(
        const level : string;
        const msg : string;
        const context : ISerializeable = nil
    ) : ILogger;
    begin
        firstLogger.log(level, msg, context);
        secondLogger.log(level, msg, context);
        result := self;
    end;

end.

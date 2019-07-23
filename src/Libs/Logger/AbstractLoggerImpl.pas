{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit AbstractLoggerImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    SerializeableIntf,
    LoggerIntf,
    InjectableObjectImpl;

type

    (*!------------------------------------------------
     * base for any class having capability to log
     * message
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TAbstractLogger = class(TInjectableObject, ILogger)
    public

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
        ) : ILogger; virtual; abstract;

        (*!--------------------------------------
         * log critical message
         * --------------------------------------
         * @param msg log message
         * @param context data related to log message
         *               (if any)
         * @return current instance
         *---------------------------------------*)
        function critical(const msg : string; const context : ISerializeable = nil) : ILogger;

        (*!--------------------------------------
         * log debug message
         * --------------------------------------
         * @param msg log message
         * @param context data related to log message
         *               (if any)
         * @return current instance
         *---------------------------------------*)
        function debug(const msg : string; const context : ISerializeable  = nil) : ILogger;

        (*!--------------------------------------
         * log info message
         * --------------------------------------
         * @param msg log message
         * @param context data related to log message
         *               (if any)
         * @return current instance
         *---------------------------------------*)
        function info(const msg : string; const context : ISerializeable = nil) : ILogger;

        (*!--------------------------------------
         * log warning message
         * --------------------------------------
         * @param msg log message
         * @param context data related to log message
         *               (if any)
         * @return current instance
         *---------------------------------------*)
        function warning(const msg : string; const context : ISerializeable = nil) : ILogger;
    end;

implementation

    (*!--------------------------------------
     * log critical message
     * --------------------------------------
     * @param msg log message
     * @param context data related to log message
     *               (if any)
     * @return current instance
     *---------------------------------------*)
    function TAbstractLogger.critical(const msg : string; const context : ISerializeable = nil) : ILogger;
    begin
        result := log('CRITICAL', msg, context);
    end;

    (*!--------------------------------------
     * log debug message
     * --------------------------------------
     * @param msg log message
     * @param context data related to log message
     *               (if any)
     * @return current instance
     *---------------------------------------*)
    function TAbstractLogger.debug(const msg : string; const context : ISerializeable  = nil) : ILogger;
    begin
        result := log('DEBUG', msg, context);
    end;

    (*!--------------------------------------
     * log info message
     * --------------------------------------
     * @param msg log message
     * @param context data related to log message
     *               (if any)
     * @return current instance
     *---------------------------------------*)
    function TAbstractLogger.info(const msg : string; const context : ISerializeable = nil) : ILogger;
    begin
        result := log('INFO', msg, context);
    end;

    (*!--------------------------------------
     * log warning message
     * --------------------------------------
     * @param msg log message
     * @param context data related to log message
     *               (if any)
     * @return current instance
     *---------------------------------------*)
    function TAbstractLogger.warning(const msg : string; const context : ISerializeable = nil) : ILogger;
    begin
        result := log('WARNING', msg, context);
    end;

end.

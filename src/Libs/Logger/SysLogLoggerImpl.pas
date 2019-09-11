{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit SysLogLoggerImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    SerializeableIntf,
    LoggerIntf,
    AbstractLoggerImpl;

type

    (*!------------------------------------------------
     * logger class that output to system log (syslog)
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TSysLogLogger = class(TAbstractLogger)
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
        ) : ILogger; override;
    end;

implementation

uses

    SysUtils,
    SystemLog;

    function mapPriority(const level : string) : integer;
    begin
        result := LOG_EMERG;
        case (level) of
            'INFO' : result := LOG_INFO;
            'CRITICAL' : result := LOG_CRIT;
            'DEBUG' : result := LOG_DEBUG;
            'WARNING' : result := LOG_WARNING;
            'ERROR' : result := LOG_ERROR;
            'EMERGENCY' : result := LOG_EMERG;
            'NOTICE' : result := LOG_NOTICE;
            'ALERT' : result := LOG_ALERT;
        end;
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
    function TSysLogLogger.log(
        const level : string;
        const msg : string;
        const context : ISerializeable = nil
    ) : ILogger;
    var contextMsg : string;
    begin
        contextMsg := '';
        if (context <> nil) then
        begin
            contextMsg := '==== Start context ====' + LineEnding +
                context.serialize() + LineEnding +
                '==== End context ====' + LineEnding;
        end;
        syslog(mapPriority(level), msg + LineEnding + '%s', [contextMsg]);
        result := self;
    end;

end.

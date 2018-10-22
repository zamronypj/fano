{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}

unit AbstractLoggerImpl;

interface

{$H+}

uses

    DependencyIntf,
    SerializeableIntf,
    LoggerIntf;

type

  (*!------------------------------------------------
   * base for any class having capability to log
   * message
   *
   * @author Zamrony P. Juhara <zamronypj@yahoo.com>
   *-----------------------------------------------*)
    TAbstractLogger = class(TInterfacedObject, IDependency, ILogger)
    public
        function log(
            const level : TLogLevel;
            const msg : string;
            const context : ISerializeable = nil
        ) : ILogger; virtual; abstract;

        function critical(const msg : string; const context : ISerializeable = nil) : ILogger;
        function debug(const msg : string; const context : ISerializeable  = nil) : ILogger;
        function info(const msg : string; const context : ISerializeable = nil) : ILogger;
        function warning(const msg : string; const context : ISerializeable = nil) : ILogger;
    end;

implementation

    function TAbstractLogger.critical(const msg : string; const context : ISerializeable = nil) : ILogger;
    begin
        result := log(lvlCritical, msg, context);
    end;

    function TAbstractLogger.debug(const msg : string; const context : ISerializeable  = nil) : ILogger;
    begin
        result := log(lvlDebug, msg, context);
    end;

    function TAbstractLogger.info(const msg : string; const context : ISerializeable = nil) : ILogger;
    begin
        result := log(lvlInfo, msg, context);
    end;

    function TAbstractLogger.warning(const msg : string; const context : ISerializeable = nil) : ILogger;
    begin
        result := log(lvlWarning, msg, context);
    end;

end.

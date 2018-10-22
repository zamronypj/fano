{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}

unit NullLoggerImpl;

interface

{$H+}

uses

    DependencyIntf,
    SerializeableIntf,
    LoggerIntf,
    AbstractLoggerImpl;

type

  (*!------------------------------------------------
   * logger class that does not anything
   *
   * @author Zamrony P. Juhara <zamronypj@yahoo.com>
   *-----------------------------------------------*)
    TNullLogger = class(TAbstractLogger, IDependency, ILogger)
    public
        function log(
            const level : TLogLevel;
            const msg : string;
            const context : ISerializeable = nil
        ) : ILogger; override;
    end;

implementation

    function TNullLogger.log(
        const level : TLogLevel;
        const msg : string;
        const context : ISerializeable = nil
    ) : ILogger;
    begin
        result := self;
    end;

end.

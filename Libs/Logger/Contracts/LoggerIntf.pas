{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit LoggerIntf;

interface

{$MODE OBJFPC}
{$H+}

uses

    SerializeableIntf;

type

    (*!------------------------------------------------
     * interface for any class having capability to log
     * message
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    ILogger = interface
        ['{A2334E59-76CC-4FCC-83BC-B694963D4B1A}']

        function log(
            const level : string;
            const msg : string;
            const context : ISerializeable = nil
        ) : ILogger;

        function critical(const msg : string; const context : ISerializeable = nil) : ILogger;
        function debug(const msg : string; const context : ISerializeable  = nil) : ILogger;
        function info(const msg : string; const context : ISerializeable = nil) : ILogger;
        function warning(const msg : string; const context : ISerializeable = nil) : ILogger;
    end;

implementation

end.

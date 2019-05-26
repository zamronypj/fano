{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit FcgiProcessorIntf;

interface

{$MODE OBJFPC}
{$H+}

uses

    EnvironmentIntf;

type

    (*!-----------------------------------------------
     * Interface for any class having capability to process
     * FastCGI stream from web server
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IFcgiProcessor = interface(IRequest)
        ['{D702F184-8CA5-48AC-AC71-6E5C4EE02382}']

        (*!------------------------------------------------
        * process request stream
        *-----------------------------------------------
        * @return true if all data from web server is ready to
        * be handle by application (i.e, environment, STDIN already parsed)
        *-----------------------------------------------*)
        function process(const stream : IStreamAdapter) : boolean;

        (*!------------------------------------------------
        * get current environment
        *-----------------------------------------------
        * @return environment
        *-----------------------------------------------*)
        function getEnvironment() : ICGIEnvironment;

        (*!------------------------------------------------
        * write string to FCGI_STDOUT stream and
        * mark it end of request
        *-----------------------------------------------
        * @return current instance
        *-----------------------------------------------*)
        function write(const stream : IStreamAdapter; const str : string)  : IFcgiProcessor;

    end;

implementation

end.

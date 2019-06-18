{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FcgiProcessorIntf;

interface

{$MODE OBJFPC}
{$H+}

uses

    EnvironmentIntf,
    StreamAdapterIntf;

type

    (*!-----------------------------------------------
     * Interface for any class having capability to process
     * FastCGI stream from web server
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IFcgiProcessor = interface
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
         * get current FCGI_STDIN complete stream
         *-----------------------------------------------
         * @return stream
         *-----------------------------------------------*)
        function getStdInStream() : IStreamAdapter;
    end;

implementation

end.

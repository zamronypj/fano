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

    StreamAdapterIntf,
    CloseableIntf,
    FcgiRequestReadyListenerIntf;

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
         *-----------------------------------------------*)
        procedure process(const stream : IStreamAdapter; const streamCloser : ICloseable);

        (*!------------------------------------------------
         * get FastCGI StdIn stream for complete request
         *-----------------------------------------------*)
        function getStdIn() : IStreamAdapter;

        (*!------------------------------------------------
         * set listener to be notified weh request is ready
         *-----------------------------------------------
         * @return current instance
         *-----------------------------------------------*)
        function setReadyListener(const listener : IFcgiRequestReadyListener) : IFcgiProcessor;
    end;

implementation

end.

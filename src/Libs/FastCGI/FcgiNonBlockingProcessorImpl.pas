{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FcgiNonBlockingProcessorImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    ListIntf,
    StreamAdapterIntf,
    CloseableIntf,
    StreamIdIntf,
    ReadyListenerIntf,
    StdInStreamAwareIntf,
    FcgiRequestIdAwareIntf,
    ProtocolProcessorIntf,
    NonBlockingProtocolProcessorImpl;

type

    (*!-----------------------------------------------
     * class having capability to process
     * stream from web server in non-blocking fashion
     * this class basically just collect all data until
     * it is completed, then it calls actual processor
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiNonBlockingProcessor = class(TNonBlockingProtocolProcessor, IFcgiRequestIdAware, IStdInStreamAware)
    private
        fRequestIdAware : IFcgiRequestIdAware;
    public
        constructor create(
            const actualProcessor : IProtocolProcessor;
            const buffList : IList;
            const reqIdAware : IFcgiRequestIdAware
        );
        destructor destroy(); override;

        (*!------------------------------------------------
         * get request id
         *-----------------------------------------------
         * @return request id
         *-----------------------------------------------*)
        function getRequestId() : word;

    end;

implementation

    constructor TFcgiNonBlockingProcessor.create(
        const actualProcessor : IProtocolProcessor;
        const buffList : IList;
        const reqIdAware : IFcgiRequestIdAware
    );
    begin
        inherited create(actualProcessor, buffList);
        fRequestIdAware := reqIdAware;
    end;

    destructor TFcgiNonBlockingProcessor.destroy();
    begin
        fRequestIdAware := nil;
        inherited destroy();
    end;

    (*!------------------------------------------------
     * get request id
     *-----------------------------------------------
     * @return request id
     *-----------------------------------------------*)
    function TFcgiNonBlockingProcessor.getRequestId() : word;
    begin
        result := fRequestIdAware.getRequestId();
    end;


end.

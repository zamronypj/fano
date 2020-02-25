{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit MhdProcessorImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    libmicrohttpd,
    StreamAdapterIntf,
    CloseableIntf,
    RunnableIntf,
    RunnableWithDataNotifIntf,
    ProtocolProcessorIntf,
    StreamIdIntf,
    ReadyListenerIntf,
    DataAvailListenerIntf,
    EnvironmentIntf,
    MhdConnectionAwareIntf;

type

    (*!-----------------------------------------------
     * Class which can process request from libmicrohttpd web server
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TMhdProcessor = class(TInterfacedObject, IProtocolProcessor, IRunnable, IRunnableWithDataNotif)
    private
        fPort : word;
        fHost : string;
        fTimeout : longword;
        fRequestReadyListener : IReadyListener;
        fDataListener : IDataAvailListener;
        fStdIn : IStreamAdapter;
        fConnectionAware : IMhdConnectionAware;

        procedure resetInternalVars();
        procedure waitUntilTerminate();

        function buildEnv(
            aconnection : PMHD_Connection;
            aurl : pcchar;
            amethod : pcchar;
            aversion : pcchar
        ): ICGIEnvironment;

        function handleReq(
            aconnection : PMHD_Connection;
            aurl : pcchar;
            amethod : pcchar;
            aversion : pcchar;
            aupload_data : pcchar;
            aupload_data_size : psize_t;
            aptr : ppointer
        ): cint;

    public
        constructor create(
            const aConnectionAware : IMhdConnectionAware;
            const host : string;
            const port : word;
            const timeout : longword = 120
        );
        destructor destroy(); override;

        (*!------------------------------------------------
         * process request stream
         *-----------------------------------------------*)
        function process(
            const stream : IStreamAdapter;
            const streamCloser : ICloseable;
            const streamId : IStreamId
        ) : boolean;

        (*!------------------------------------------------
         * get StdIn stream for complete request
         *-----------------------------------------------*)
        function getStdIn() : IStreamAdapter;

        (*!------------------------------------------------
         * set listener to be notified when request is ready
         *-----------------------------------------------
         * @return current instance
         *-----------------------------------------------*)
        function setReadyListener(const listener : IReadyListener) : IProtocolProcessor;

        (*!------------------------------------------------
         * get number of bytes of complete request based
         * on information buffer
         *-----------------------------------------------
         * @return number of bytes of complete request
         *-----------------------------------------------*)
        function expectedSize(const buff : IStreamAdapter) : int64;

        (*!------------------------------------------------
         * run it
         *-------------------------------------------------
         * @return current instance
         *-------------------------------------------------*)
        function run() : IRunnable;

        (*!------------------------------------------------
        * set instance of class that will be notified when
        * data is available
        *-----------------------------------------------
        * @param dataListener, class that wish to be notified
        * @return true current instance
        *-----------------------------------------------*)
        function setDataAvailListener(const dataListener : IDataAvailListener) : IRunnableWithDataNotif;
    end;

implementation

uses

    Classes,
    BaseUnix,
    SysUtils,
    TermSignalImpl,
    KeyValueEnvironmentImpl,
    MhdParamKeyValuePairImpl,
    StreamAdapterImpl,
    NullStreamAdapterImpl;

    constructor TMhdProcessor.create(
        const aConnectionAware : IMhdConnectionAware;
        const host : string;
        const port : word;
        const timeout : longword = 120
    );
    begin
        inherited create();
        fHost := host;
        fPort := port;
        fTimeout := timeout;
        fRequestReadyListener := nil;
        fDataListener := nil;
        fStdIn := nil;
        fConnectionAware := aConnectionAware;
    end;

    destructor TMhdProcessor.destroy();
    begin
        resetInternalVars();
        inherited destroy();
    end;

    procedure TMhdProcessor.resetInternalVars();
    begin
        fRequestReadyListener := nil;
        fDataListener := nil;
        fStdIn := nil;
        fConnectionAware := nil;
    end;

    (*!------------------------------------------------
     * process request stream
     *-----------------------------------------------*)
    function TMhdProcessor.process(
        const stream : IStreamAdapter;
        const streamCloser : ICloseable;
        const streamId : IStreamId
    ) : boolean;
    begin
        //intentationally does nothing, because libmicrohttpd
        //already does stream parsing so this is not relevant
        result := true;
    end;

    (*!------------------------------------------------
     * get StdIn stream for complete request
     *-----------------------------------------------*)
    function TMhdProcessor.getStdIn() : IStreamAdapter;
    begin
        result := fStdIn;
    end;

    (*!------------------------------------------------
     * set listener to be notified weh request is ready
     *-----------------------------------------------
     * @return current instance
     *-----------------------------------------------*)
    function TMhdProcessor.setReadyListener(const listener : IReadyListener) : IProtocolProcessor;
    begin
        fRequestReadyListener := listener;
        result := self;
    end;

    (*!------------------------------------------------
     * get number of bytes of complete request based
     * on information buffer
     *-----------------------------------------------
     * @return number of bytes of complete request
     *-----------------------------------------------*)
    function TMhdProcessor.expectedSize(const buff : IStreamAdapter) : int64;
    begin
        result := 0;
    end;

    procedure TMhdProcessor.waitUntilTerminate();
    var fds : TFDSet;
    begin
        fds := default(TFDSet);
        fpfd_zero(fds);
        //terminatePipeIn will be ready for IO when application is terminated
        //see TermSignalImpl unit
        fpfd_set(terminatePipeIn, FDS);
        //wait forever until terminatePipeIn changes
        fpSelect(terminatePipeIn + 1, @fds, nil, nil, nil);
    end;

    //BaseUnix and libmicrohttpd both declared pcchar type
    //here any pcchar use libmicrohttpd.pcchar,
    //otherwise FPC complains about type mismatch
    function handleRequestCallback(
        acontext :  pointer;
        aconnection : PMHD_Connection;
        aurl : libmicrohttpd.pcchar;
        amethod : libmicrohttpd.pcchar;
        aversion : libmicrohttpd.pcchar;
        aupload_data : libmicrohttpd.pcchar;
        aupload_data_size : libmicrohttpd.psize_t;
        aptr : ppointer
    ): cint; cdecl;
    begin
        result := TMhdProcessor(acontext).handleReq(
            aconnection,
            aurl,
            amethod,
            aversion,
            aupload_data,
            aupload_data_size,
            aptr
        );
    end;

    function TMhdProcessor.buildEnv(
        aconnection : PMHD_Connection;
        aurl : libmicrohttpd.pcchar;
        amethod : libmicrohttpd.pcchar;
        aversion : libmicrohttpd.pcchar
    ): ICGIEnvironment;
    var
        mhdData : TMhdData;
    begin
        mhdData.connection := aconnection;
        mhdData.url := aurl;
        mhdData.method := amethod;
        result := TKeyValueEnvironment.create(
            TMhdParamKeyValuePair.create(mhdData)
        );
    end;

    function TMhdProcessor.handleReq(
        aconnection : PMHD_Connection;
        aurl : libmicrohttpd.pcchar;
        amethod : libmicrohttpd.pcchar;
        aversion : libmicrohttpd.pcchar;
        aupload_data : libmicrohttpd.pcchar;
        aupload_data_size : psize_t;
        aptr : ppointer
    ): cint;
    var
        mhdEnv : ICGIEnvironment;
        mhdStream : IStreamAdapter;
        mem : TMemoryStream;
    begin
        result := MHD_NO;
        if (aptr^ = nil) then
        begin
            //begin of request
            mem := TMemoryStream.create();
            if (aupload_data_size^ > 0) then
            begin
                mem.writeBuffer(aupload_data^, aupload_data_size^);
            end;
            aptr^ := mem;
        end else
        begin
            mem := TMemoryStream(aptr^);

            if (aupload_data_size^ = 0) then
            begin
                //request is complete
                fConnectionAware.connection := aconnection;
                mhdEnv := buildEnv(aconnection, aurl, amethod, aversion);
                mhdStream := TStreamAdapter.create(mem);
                fRequestReadyListener.ready(
                    //we will not use this in
                    TNullStreamAdapter.create(),
                    mhdEnv,
                    mhdStream
                );
                result := MHD_YES;
            end else
            begin
                mem.writeBuffer(aupload_data^, aupload_data_size^);
            end;
        end;
    end;

    (*!------------------------------------------------
     * run it
     *-------------------------------------------------
     * @return current instance
     *-------------------------------------------------*)
    function TMhdProcessor.run() : IRunnable;
    var
        svrDaemon : PMHD_Daemon;
    begin
        svrDaemon := MHD_start_daemon(
            MHD_USE_EPOLL_INTERNALLY_LINUX_ONLY,
            fPort,
            nil,
            nil,
            @handleRequestCallback,
            self,
            MHD_OPTION_CONNECTION_TIMEOUT,
            cuint(fTimeout),
            MHD_OPTION_END
        );
        if svrDaemon <> nil then
        begin
            waitUntilTerminate();
            MHD_stop_daemon(svrDaemon);
        end;
        result := self;
    end;

    (*!------------------------------------------------
     * set instance of class that will be notified when
     * data is available
     *-----------------------------------------------
     * @param dataListener, class that wish to be notified
     * @return true current instance
     *-----------------------------------------------*)
    function TMhdProcessor.setDataAvailListener(const dataListener : IDataAvailListener) : IRunnableWithDataNotif;
    begin
        fDataListener := dataListener;
    end;
end.

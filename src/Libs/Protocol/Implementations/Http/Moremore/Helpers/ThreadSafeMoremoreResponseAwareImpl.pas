{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2022 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ThreadSafeMoremoreResponseAwareImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    mormot.net.http,
    SyncObjs,
    StdOutIntf,
    MoremoreResponseAwareIntf,
    ThreadSafeStdOutImpl,
    StreamAdapterIntf;

type

    (*!------------------------------------------------
     * IStdOut implementation class THttpAsyncServer response
     * instance in thread-safe way
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TThreadSafeMoremoreResponseAware = class(TThreadSafeStdOut, IMoremoreResponseAware)
    private
        fActualResponseAware : IMoremoreResponseAware;
    public
        constructor create(
            const lock : TCriticalSection;
            const actualStdOut : IStdOut;
            const actualResponseAware : IMoremoreResponseAware
        );

        (*!------------------------------------------------
         * get THTTPAsyncServer response connection
         *-----------------------------------------------
         * @return connection
         *-----------------------------------------------*)
        function getResponse() : THttpServerRequestAbstract;

        (*!------------------------------------------------
         * set THttpServerRequestAbstract response object
         *-----------------------------------------------*)
        procedure setResponse(aresponse: THttpServerRequestAbstract);

        property response: THttpServerRequestAbstract read getResponse write setResponse;
    end;

implementation

    constructor TThreadSafeMoremoreResponseAware.create(
        const lock : TCriticalSection;
        const actualStdOut : IStdOut;
        const actualResponseAware : IMoremoreResponseAware
    );
    begin
        inherited create(lock, actualStdOut);
        fActualResponseAware := actualResponseAware;
    end;

    (*!------------------------------------------------
     * get THTTPAsyncServer response connection
     *-----------------------------------------------
     * @return connection
     *-----------------------------------------------*)
    function TThreadSafeMoremoreResponseAware.getResponse() : THttpServerRequestAbstract;
    begin
        fLock.acquire();
        try
            result := fActualResponseAware.getResponse();
        finally
            fLock.release();
        end;
    end;

    (*!------------------------------------------------
     * set THttpServerRequestAbstract response object
     *-----------------------------------------------*)
    procedure TThreadSafeMoremoreResponseAware.setResponse(aresponse : THttpServerRequestAbstract);
    begin
        fLock.acquire();
        try
            fActualResponseAware.setResponse(aresponse);
        finally
            fLock.release();
        end;
    end;

end.

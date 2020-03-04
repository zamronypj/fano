{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ThreadSafeRdbmsPoolImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    syncobjs,
    RdbmsIntf,
    RdbmsPoolIntf,
    InjectableObjectImpl;

type

    (*!------------------------------------------------
     * basic class having capability to
     * handle database connection pool
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TThreadSafeRdbmsPool = class(TInjectableObject, IRdbmsPool)
    private
        fActualPool : IRdbmsPool;
        fPoolEvent : TSimpleEvent;
        fCriticalSection : TCriticalSection;
    public
        constructor create(const pool : IRdbmsPool);
        destructor destroy(); override;

        (*!------------------------------------------------
         * get rdbms connection from pool
         *-------------------------------------------------
         * @return database connection instance
         *-------------------------------------------------*)
        function acquire() : IRdbms;

        (*!------------------------------------------------
         * release rdbms connection back into pool
         *-------------------------------------------------
         * @return database connection instance
         *-------------------------------------------------*)
        procedure release(const conn : IRdbms);

        (*!------------------------------------------------
         * get total rdbms connection in pool
         *-------------------------------------------------
         * @return number of connection in pool
         *-------------------------------------------------*)
        function count() : integer;

        (*!------------------------------------------------
         * get total available rdbms connection in pool
         *-------------------------------------------------
         * @return number of available connection in pool
         *-------------------------------------------------*)
        function availableCount() : integer;

        (*!------------------------------------------------
         * get total used rdbms connection in pool
         *-------------------------------------------------
         * @return number of used connection in pool
         *-------------------------------------------------*)
        function usedCount() : integer;
    end;

implementation

uses

    SysUtils,
    fgl,
    EPoolConnectionImpl;

resourcestring

    sErrPoolConnNotAvail = 'No available connections to acquire';
    sErrPoolConnNotUsed = 'No used connections to release';

    constructor TThreadSafeRdbmsPool.create(const pool : IRdbmsPool);
    begin
        fActualPool := pool;
        fPoolEvent := TSimpleEvent.create();
        fCriticalSection := TCriticalSection.create();
    end;

    destructor TThreadSafeRdbmsPool.destroy();
    begin
        fPoolEvent.free();
        fCriticalSection.free();
        fActualPool := nil;
        inherited destroy();
    end;


    (*!------------------------------------------------
     * get rdbms connection from pool
     *-------------------------------------------------
     * @return database connection instance
     *-------------------------------------------------*)
    function TThreadSafeRdbmsPool.acquire() : IRdbms;
    begin
        //block thread until pool is available
        fPoolEvent.waitFor(INFINITE)
        result := fActualPool.acquire();

        if availableCount() = 0 then
        begin
            //reset event so when other thread tries to acquire, it blocks.
            fPoolEvent.resetEvent();
        end;
    end;

    (*!------------------------------------------------
     * release rdbms connection back into pool
     *-------------------------------------------------
     * @return database connection instance
     *-------------------------------------------------*)
    procedure TThreadSafeRdbmsPool.release(const conn : IRdbms);
    begin
        fCriticalSection.acquire();
        try
            fActualPool.release(conn);
            if fActualPool.availableCount() > 0 then
            begin
                fPoolEvent.setEvent();
            end;
        finally
            fCriticalSection.release();
        end;
    end;

    (*!------------------------------------------------
     * get total rdbms connection in pool
     *-------------------------------------------------
     * @return number of connection in pool
     *-------------------------------------------------*)
    function TThreadSafeRdbmsPool.count() : integer;
    begin
        fCriticalSection.acquire();
        try
            result := fActualPool.count();
        finally
            fCriticalSection.release();
        end;
    end;

    (*!------------------------------------------------
     * get total available rdbms connection in pool
     *-------------------------------------------------
     * @return number of available connection in pool
     *-------------------------------------------------*)
    function TThreadSafeRdbmsPool.availableCount() : integer;
    begin
        fCriticalSection.acquire();
        try
            result := fActualPool.availableCount();
        finally
            fCriticalSection.release();
        end;
    end;

    (*!------------------------------------------------
     * get total used rdbms connection in pool
     *-------------------------------------------------
     * @return number of used connection in pool
     *-------------------------------------------------*)
    function TThreadSafeRdbmsPool.usedCount() : integer;
    begin
        fCriticalSection.acquire();
        try
            result := fActualPool.usedCount();
        finally
            fCriticalSection.release();
        end;
    end;
end.

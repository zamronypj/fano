{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2020 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit DbSessionManagerImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    SessionIntf,
    SessionIdGeneratorIntf,
    SessionManagerIntf,
    SessionFactoryIntf,
    RequestIntf,
    RdbmsIntf,
    ListIntf,
    AbstractSessionManagerImpl;

type

    (*!------------------------------------------------
     * Data structure for session table information
     *-----------------------------------------------*)
    TSessionTableInfo = record
        //name of session table
        tableName : string;

        //name of session id column
        sessionIdColumn : string;

        //name of session data column
        dataColumn : string;

        //name of expired at column
        expiredAtColumn : string;
    end;

    (*!------------------------------------------------
     * class having capability to manage
     * session variables in RDBMS database
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TDbSessionManager = class(TAbstractSessionManager)
    private
        fRdbms : IRdbms;
        fSessTableInfo : TSessionTableInfo;

        function getSessionDb(
            const sessId : string;
            out sessData : string;
            out expiredAt : TDateTime
        ) : boolean;

        function createSessionDb(
            const sessId : string;
            const sessData : string;
            const expiredAt : TDateTime
        ) : boolean;
        function updateSessionDb(
            const sessId : string;
            const sessData : string;
            const expiredAt : TDateTime
        ) : boolean;

        (*!------------------------------------
         * create session from session id
         *-------------------------------------
         * @param sessionId session id
         * @return session instance or nil if not found
         *-------------------------------------
         * if sessionId point to valid session id in storage,
         * then new ISession is created with is data populated
         * from storage.
         *
         * if sessionId is empty string or invalid
         * or expired, returns nil
         *-------------------------------------*)
        function findSession(const sessionId : string) : ISession;

        (*!------------------------------------
         * create session from session id
         *-------------------------------------
         * @param sessionId session id
         * @param lifeTimeInSec life time of session in seconds
         * @return session instance
         *-------------------------------------
         * if sessionId point to valid session id in storage,
         * then new ISession is created with is data populated
         * from storage. lifeTimeInSec parameter is ignored
         *
         * if sessionId is empty string or invalid
         * or expired, new ISession is created with empty
         * data, session life time is set to lifeTime value
         *-------------------------------------*)
        function createSession(
            const request : IRequest;
            const sessionId : string;
            const lifeTimeInSec : integer
        ) : ISession;

        (*!------------------------------------
         * end session and persist to storage
         *-------------------------------------
         * @param session session instance
         * @return current instance
         *-------------------------------------*)
        function persistSession(
            const session : ISession
        ) : ISessionManager;

        (*!------------------------------------
         * end session and remove its storage
         *-------------------------------------
         * @param session session instance
         * @return current instance
         *-------------------------------------*)
        function destroySession(
            const session : ISession
        ) : ISessionManager;

        procedure cleanUpSessionList();
    public

        (*!------------------------------------
         * constructor
         *-------------------------------------
         * @param sessionIdGenerator helper class
         *           which can generate session id
         * @param sessionFactory helper class
         *           which create ISession object
         * @param cookieName name of cookie to use
         * @param rbmds rdbms instance
         * @param sessTableInfo session table information
         *-------------------------------------*)
        constructor create(
            const sessionIdGenerator : ISessionIdGenerator;
            const sessionFactory : ISessionFactory;
            const cookieName : string;
            const rdbms : IRdbms;
            const sessTableInfo : TSessionTableInfo
        );

        (*!------------------------------------
         * destructor
         *-------------------------------------*)
        destructor destroy(); override;

        (*!------------------------------------
         * create session from request
         *-------------------------------------
         * @param request current request instance
         * @param lifeTimeInSec life time of session in seconds
         * @return session instance
         *-------------------------------------*)
        function beginSession(
            const request : IRequest;
            const lifeTimeInSec : integer
        ) : ISession; override;

        (*!------------------------------------
         * get session from request
         *-------------------------------------
         * @param request current request instance
         * @return session instance or nil if not found
         *-------------------------------------*)
        function getSession(const request : IRequest) : ISession; override;

        (*!------------------------------------
         * end session and save session data to
         * persistent storage
         *-------------------------------------
         * @param session session instance
         * @return current instance
         *-------------------------------------*)
        function endSession(
            const session : ISession
        ) : ISessionManager; override;

    end;

implementation

uses

    SysUtils,
    DateUtils,
    SessionConsts,
    HashListImpl,
    RdbmsStatementIntf,
    RdbmsResultSetIntf,
    ESessionExpiredImpl,
    ESessionInvalidImpl;

type

    TSessionItem = record
        sessionObj : ISession;
    end;
    PSessionItem = ^TSessionItem;

    (*!------------------------------------
     * constructor
     *-------------------------------------
     * @param sessionIdGenerator helper class
     *           which can generate session id
     * @param sessionFactory helper class
     *           which create ISession object
     * @param cookieName name of cookie to use
     * @param rbmds rdbms instance
     * @param sessTableInfo session table information
     *-------------------------------------*)
    constructor TDbSessionManager.create(
        const sessionIdGenerator : ISessionIdGenerator;
        const sessionFactory : ISessionFactory;
        const cookieName : string;
        const rdbms : IRdbms;
        const sessTableInfo : TSessionTableInfo
    );
    begin
        inherited create(sessionIdGenerator, cookieName);
        fSessionFactory := sessionFactory;
        fRdbms := rdbms;
        fSessTableInfo := sessTableInfo;
    end;

    (*!------------------------------------
     * destructor
     *-------------------------------------*)
    destructor TDbSessionManager.destroy();
    begin
        fCurrentSession := nil;
        cleanUpSessionList();
        fRbms := nil;
        fSessionFactory := nil;
        inherited destroy();
    end;

    procedure TDbSessionManager.cleanUpSessionList();
    var indx : integer;
        item : PSessionItems;
    begin
        for indx := fSessionList.count()-1  downto 0 do
        begin
            item := fSessionList.get(indx);
            item^.sessionObj := nil;
            dispose(item);
            fSessionList.delete(indx);
        end;
    end;

    function TDbSessionManager.getSessionDb(
        const sessId : string;
        out sessData : string;
        out expiredAt : TDateTime
    ) : boolean;
    var sts : IRdbmsStatement;
        res : IRdbmsResultSet;
    begin
        result := false;
        sts := fRdbms.prepare(
            'SELECT ' +
                '`' + fSessTableInfo.dataColumn + '`, ' +
                '`' +fSessTableInfo.expiredAtColumn + '`' +
            ' FROM `' + fSessTableInfo.tableName + '` ' +
            'WHERE ' + fSessTableInfo.sessionIdColumn + ' = :sessId'
        );
        sts.paramStr('sessId', sessId);
        res := sts.execute();
        if res.resultCount <> 0 then
        begin
            result := true;
            sessData := res.fields.fieldByName(fSessTableInfo.dataColumn).asString;
            expiredAt := res.fields.fieldByName(fSessTableInfo.expiredAtColumn).asDateTime;
        end;
    end;

    function TDbSessionManager.createSessionDb(
        const sessId : string;
        const sessData : string;
        const expiredAt : TDateTime
    ) : boolean;
    var sts : IRdbmsStatement;
    begin
        sts := fRdbms.prepare(
            'INSERT INTO `' + fSessTableInfo.tableName + '` ' +
            '( ' +
                '`' + fSessTableInfo.sessionIdColumn + '`,'
                '`' + fSessTableInfo.dataColumn + '`, ' +
                '`' + fSessTableInfo.expiredAtColumn + '`' +
            ') VALUES (:sessId, :sessData, :expiredAt)'
        );
        sts.paramStr('sessId', sessId);
        sts.paramDateTime('expiredAt', expiredAt);
        sts.paramStr('sessData', sessData);
        sts.execute();
        result := true;
    end;

    function TDbSessionManager.updateSessionDb(
        const sessId : string;
        const sessData : string;
        const expiredAt : TDateTime
    ) : boolean;
    var sts : IRdbmsStatement;
    begin
        sts := fRdbms.prepare(
            'UPDATE `' + fSessTableInfo.tableName + '` ' +
            'SET ' +
            fSessTableInfo.dataColumn + ' = :sessData, ' +
            fSessTableInfo.expiredAtColumn + '= :expiredAt ' +
            'WHERE ' + fSessTableInfo.sessionIdColumn + ' = :sessId'
        );
        sts.paramStr('sessId', sessId);
        sts.paramDateTime('expiredAt', expiredAt);
        sts.paramStr('sessData', sessData);
        sts.execute();
        result := true;
    end;

    (*!------------------------------------
     * find session from session id
     *-------------------------------------
     * @param sessionId session id
     * @return session instance or nil if not found
     *-------------------------------------
     * if sessionId point to valid session id in storage,
     * then new ISession is created with is data populated
     * from storage. lifeTimeInSec parameter is ignored
     *
     * if sessionId is empty string or invalid
     * or expired, return nil
     *-------------------------------------*)
    function TDbSessionManager.findSession(const sessionId : string) : ISession;
    var sessData : string;
        expiry : TDateTime;
    begin
        result := nil;
        if (sessionId <> '') and (getSessionDb(sessionId, sessData, expiry)) then
        begin
            try
                result := fSessionFactory.createSession(
                    fCookieName,
                    sessionId,
                    sessData,
                    expiry
                );
            except
                on ESessionExpired do
                begin
                    freeAndNil(result);
                end;
            end;
        end;
    end;

    (*!------------------------------------
     * create session from session id
     *-------------------------------------
     * @param sessionId session id
     * @param lifeTimeInSec life time of session in seconds
     * @return session instance
     *-------------------------------------
     * if sessionId point to valid session id in storage,
     * then new ISession is created with is data populated
     * from storage. lifeTimeInSec parameter is ignored
     *
     * if sessionId is empty string or invalid
     * or expired, new ISession is created with empty
     * data, session life time is set to lifeTime value
     *-------------------------------------*)
    function TDbSessionManager.createSession(
        const request : IRequest;
        const sessionId : string;
        const lifeTimeInSec : integer
    ) : ISession;
    var sess : ISession;
    begin
        sess := findSession(sessionId);

        if sess = nil then
        begin
            sess := fSessionFactory.createNewSession(
                fCookieName,
                fSessionIdGenerator.getSessionId(request),
                incSecond(now(), lifeTimeInSec)
            );
        end;

        result := sess;
    end;

    (*!------------------------------------
     * create session from request
     *-------------------------------------
     * @param request current request instance
     * @param lifeTimeInSec life time of session in seconds
     * @return session instance
     *-------------------------------------*)
    function TDbSessionManager.beginSession(
        const request : IRequest;
        const lifeTimeInSec : integer
    ) : ISession;
    var sessionId : string;
        sess : ISession;
        item : PSessionItem;
    begin
        try
            sessionId := request.getCookieParam(fCookieName);
            sess := createSession(request, sessionId, lifeTimeInSec);

            new(item);
            item^.sessionObj := sess;
            fSessionList.add(sess.id(), item);

            fCurrentSession := sess;
            result := sess;
        except
            on e: ESessionExpired do
            begin
                e.message := e.message + ' at begin session';
                raise;
            end;
        end;
    end;

    (*!------------------------------------
     * get session from request
     *-------------------------------------
     * @param request current request instance
     * @return session instance or nil if not found
     *-------------------------------------*)
    function TDbSessionManager.getSession(const request : IRequest) : ISession;
    var sessionId : shortstring;
        item : PSessionItem;
    begin
        sessionId := request.getCookieParam(fCookieName);
        item := fSessionList.find(sessionId);
        //it is assumed that getSession will be called between
        //beginSession() and endSession()
        //so fCurrentSession MUST NOT nil
        if (item = nil) and (fCurrentSession <> nil) then
        begin
            //if we get here, it means, this is the first request
            //so cookie is not yet set but it is initialized
            result := fCurrentSession;
        end else
        if (item <> nil) then
        begin
            result := item^.sessionObj;
        end else
        begin
            raise ESessionInvalid.create('Invalid session. Cannot get valid session');
        end;
    end;

    (*!------------------------------------
     * end session and save session data to
     * persistent storage
     *-------------------------------------
     * @param session session instance
     * @return current instance
     *-------------------------------------*)
    function TDbSessionManager.endSession(const session : ISession) : ISessionManager;
    var indx : integer;
        item : PSessionItem;
    begin
        if session.expired() then
        begin
            destroySession(session);
        end else
        begin
            persistSession(session);
        end;

        indx := fSessionList.indexOf(session.id());
        item := fSessionList.get(indx);
        item^.sessionObj := nil;
        dispose(item);
        fSessionList.delete(indx);

        fCurrentSession := nil;

        result := self;
    end;

    (*!------------------------------------
     * end session and save session data to
     * persistent storage
     *-------------------------------------
     * @param session session instance
     * @return current instance
     *-------------------------------------*)
    function TDbSessionManager.persistSession(const session : ISession) : ISessionManager;
    var sessFilename : string;
    begin
        sessFilename := fSessionFilename + session.id();
        writeSessionFile(sessFilename, session.serialize());
        session.clear();
        result := self;
    end;

    (*!------------------------------------
     * end session and delete session data from
     * persistent storage
     *-------------------------------------
     * @param session session instance
     * @return current instance
     *-------------------------------------*)
    function TDbSessionManager.destroySession(const session : ISession) : ISessionManager;
    var sessFilename : string;
    begin
        session.clear();
        sessFilename := fSessionFilename + session.id();
        if (fileExists(sessFilename)) then
        begin
            deleteFile(sessFilename);
        end;
        result := self;
    end;
end.

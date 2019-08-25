{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit JsonFileSessionManagerImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    Classes,
    fpjson,
    SessionIntf,
    SessionIdGeneratorIntf,
    SessionManagerIntf,
    RequestIntf,
    FileReaderIntf,
    ListIntf,
    AbstractSessionManagerImpl;

type

    (*!------------------------------------------------
     * class having capability to manage
     * session variables in JSON file
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TJsonFileSessionManager = class(TAbstractSessionManager)
    private
        fSessionFilename : string;
        fFileReader : IFileReader;
        fSessionList : IList;
        fCurrentSession : ISession;

        procedure writeJsonFile(const jsonFile : string; const jsonData : string);

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
         * @param cookieName name of cookie to use
         * @param fileReader helper class
         *           which can read file to string
         * @param baseDir base directory where
         *                session files store
         * @param prefix string to be prefix to
         *                session filename
         *-------------------------------------*)
        constructor create(
            const sessionIdGenerator : ISessionIdGenerator;
            const cookieName : string;
            const fileReader : IFileReader;
            const baseDir : string;
            const prefix : string
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
    jsonParser,
    DateUtils,
    SessionConsts,
    JsonSessionImpl,
    HashListImpl,
    ESessionExpiredImpl;

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
     * @param cookieName name of cookie to use
     * @param fileReader helper class
     *           which can read file to string
     * @param baseDir base directory where
     *                session files store
     * @param prefix strung to be prefix to
     *                session filename
     *-------------------------------------*)
    constructor TJsonFileSessionManager.create(
        const sessionIdGenerator : ISessionIdGenerator;
        const cookieName : string;
        const fileReader : IFileReader;
        const baseDir : string;
        const prefix : string
    );
    begin
        inherited create(sessionIdGenerator, cookieName);
        fSessionFilename := baseDir + prefix;
        fFileReader := fileReader;
        fSessionList := THashList.create();
    end;

    (*!------------------------------------
     * destructor
     *-------------------------------------*)
    destructor TJsonFileSessionManager.destroy();
    begin
        cleanUpSessionList();
        fFileReader := nil;
        fSessionList := nil;
        inherited destroy();
    end;

    procedure TJsonFileSessionManager.cleanUpSessionList();
    var indx : integer;
        item : PSessionItem;
    begin
        for indx := fSessionList.count()-1  downto 0 do
        begin
            item := fSessionList.get(indx);
            item^.sessionObj := nil;
            dispose(item);
            fSessionList.delete(indx);
        end;
    end;

    procedure TJsonFileSessionManager.writeJsonFile(const jsonFile : string; const jsonData : string);
    var fs : TFileStream;
    begin
        fs := TFileStream.create(jsonFile, fmCreate);
        try
            fs.seek(0, soFromBeginning);
            fs.writeBuffer(jsonData[1], length(jsonData));
        finally
            fs.free();
        end;
    end;

    (*!------------------------------------
     * create session from session id
     *-------------------------------------
     * @param sessionId session id
     * @return session instance or nil if not found
     *-------------------------------------
     * if sessionId point to valid session id in storage,
     * then new ISession is created with is data populated
     * from storage. lifeTimeInSec parameter is ignored
     *
     * if sessionId is empty string or invalid
     * or expired, new ISession is created with empty
     * data, session life time is set to lifeTime value
     *-------------------------------------*)
    function TJsonFileSessionManager.findSession(const sessionId : string) : ISession;
    var sess : ISession;
        sessFile : string;
    begin
        sess := nil;
        sessFile := fSessionFilename + sessionId;
        if (sessionId <> '') and (fileExists(sessFile)) then
        begin
            sess := TJsonSession.create(
                fCookieName,
                sessionId,
                fFileReader.readFile(sessFile)
            );
            try
                result := sess;
            except
                on ESessionExpired do
                begin
                    freeAndNil(sess);
                end;
            end;
        end;
        result := sess;
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
    function TJsonFileSessionManager.createSession(
        const sessionId : string;
        const lifeTimeInSec : integer
    ) : ISession;
    var sess : ISession;
        expiredDate : TDateTime;
    begin
        sess := findSession(sessionId);

        if sess = nil then
        begin
            expiredDate := incSecond(now(), lifeTimeInSec);
            sess := TJsonSession.create(
                fCookieName,
                fSessionIdGenerator.getSessionId(),
                format(
                    '{"expire": "%s", "sessionVars" : {}}',
                    [ formatDateTime('dd-mm-yyyy hh:nn:ss', expiredDate) ]
                )
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
    function TJsonFileSessionManager.beginSession(
        const request : IRequest;
        const lifeTimeInSec : integer
    ) : ISession;
    var sessionId : string;
        sess : ISession;
        item : PSessionItem;
    begin
        sessionId := request.getCookieParam(fCookieName);
        sess := createSession(sessionId, lifeTimeInSec);

        new(item);
        item^.sessionObj := sess;
        fSessionList.add(sess.id(), item);

        fCurrentSession := sess;
        result := sess;
    end;

    (*!------------------------------------
     * get session from request
     *-------------------------------------
     * @param request current request instance
     * @return session instance or nil if not found
     *-------------------------------------*)
    function TJsonFileSessionManager.getSession(const request : IRequest) : ISession;
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
            //so cookie is not yet set
            result := fCurrentSession;
        end else
        begin
            result := item^.sessionObj;
        end
    end;

    (*!------------------------------------
     * end session and save session data to
     * persistent storage
     *-------------------------------------
     * @param session session instance
     * @return current instance
     *-------------------------------------*)
    function TJsonFileSessionManager.endSession(const session : ISession) : ISessionManager;
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
     * end session and delete session data from
     * persistent storage
     *-------------------------------------
     * @param session session instance
     * @return current instance
     *-------------------------------------*)
    function TJsonFileSessionManager.persistSession(const session : ISession) : ISessionManager;
    var sessFilename : string;
    begin
        sessFilename := fSessionFilename + session.id();
        writeJsonFile(sessFilename, session.serialize());
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
    function TJsonFileSessionManager.destroySession(const session : ISession) : ISessionManager;
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

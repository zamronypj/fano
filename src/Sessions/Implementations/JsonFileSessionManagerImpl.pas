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

        procedure writeJsonFile(const jsonFile : string; const jsonData : string);

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
         * end session and save session data to
         * persistent storage
         *-------------------------------------
         * @param session session instance
         * @return current instance
         *-------------------------------------*)
        function endSession(
            const session : ISession
        ) : ISessionManager; override;

        (*!------------------------------------
         * end session and remove its storage
         *-------------------------------------
         * @param session session instance
         * @return current instance
         *-------------------------------------*)
        function destroySession(
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
    ESessionExpiredImpl;

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
    end;

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
    destructor TJsonFileSessionManager.destroy();
    begin
        fFileReader := nil;
        inherited destroy();
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
        sessFile : string;
        expiredDate : TDateTime;
    begin
        sess := nil;
        sessFile := fSessionFilename + sessionId;
        if (sessionId <> '') and (fileExists(sessFile)) then
        begin
            sess := TJsonSession.create(sessionId, fFileReader.readFile(sessFile));
            try
                result := sess;
            except
                on ESessionExpired do
                begin
                    freeAndNil(sess);
                end;
            end;
        end;

        if sess = nil then
        begin
            expiredDate := incSecond(now(), lifeTimeInSec);
            sess := TJsonSession.create(
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
    begin
        sessionId := request.getCookieParam(fCookieName);
        result := createSession(sessionId, lifeTimeInSec);
    end;

    (*!------------------------------------
     * end session and save session data to
     * persistent storage
     *-------------------------------------
     * @param session session instance
     * @return current instance
     *-------------------------------------*)
    function TJsonFileSessionManager.endSession(const session : ISession) : ISessionManager;
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

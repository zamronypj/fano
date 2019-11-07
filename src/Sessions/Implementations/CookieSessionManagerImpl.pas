{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit CookieSessionManagerImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    Classes,
    SessionIntf,
    SessionIdGeneratorIntf,
    SessionManagerIntf,
    SessionFactoryIntf,
    RequestIntf,
    ListIntf,
    EncrypterIntf,
    AbstractSessionManagerImpl;

type

    (*!------------------------------------------------
     * class having capability to manage
     * session variables in encrypted cookie
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TCookieSessionManager = class(TAbstractSessionManager)
    private
        fEncryptedSession : string;
        fSessionList : IList;
        fCurrentSession : ISession;
        fSessionFactory : ISessionFactory;
        fEncrypter : IEncrypter;
        fCookie : ICookie;

        procedure writeSessionFile(const sessFile : string; const sessData : string);

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

    public

        (*!------------------------------------
         * constructor
         *-------------------------------------
         * @param sessionIdGenerator helper class
         *           which can generate session id
         * @param sessionFactory helper class
         *           which create ISession object
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
            const sessionFactory : ISessionFactory;
            const cookieName : string;
            const cookie : ICookie;
            const encrypter : IEncrypter
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
    ESessionExpiredImpl,
    ESessionInvalidImpl;

type


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
    constructor TCookieSessionManager.create(
        const sessionIdGenerator : ISessionIdGenerator;
        const sessionFactory : ISessionFactory;
        const cookieName : string;
        const encrypter : IEncrypter
    );
    begin
        inherited create(sessionIdGenerator, cookieName);
        fSessionFactory := sessionFactory;
        fSessionFilename := baseDir + prefix;
        fCurrentSession := nil;
        fEncrypter := encrypter;
    end;

    (*!------------------------------------
     * destructor
     *-------------------------------------*)
    destructor TCookieSessionManager.destroy();
    begin
        fEncrypter := nil;
        fCurrentSession := nil;
        fSessionFactory := nil;
        inherited destroy();
    end;

    procedure TCookieSessionManager.writeSessionFile(const sessFile : string; const sessData : string);
    begin
        fEncrypter.encrypt(fSecretKey, sessData);
    end;

    (*!------------------------------------
     * create session from request
     *-------------------------------------
     * @param request current request instance
     * @param lifeTimeInSec life time of session in seconds
     * @return session instance
     *-------------------------------------*)
    function TCookieSessionManager.beginSession(
        const request : IRequest;
        const lifeTimeInSec : integer
    ) : ISession;
    var encryptedSession : string;
        sess : ISession;
    begin
        try
            encryptedSession := request.getCookieParam(fCookieName);
            sess := fSessionFactory.createNewSession(
                fCookieName,
                encryptedSession,
                incSecond(now(), lifeTimeInSec)
            );
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
    function TCookieSessionManager.getSession(const request : IRequest) : ISession;
    begin
        if fCurrentSession <> nil then
        begin
            result := fCurrentSession;
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
    function TCookieSessionManager.endSession(const session : ISession) : ISessionManager;
    begin
        if session.expired() then
        begin
            destroySession(session);
        end else
        begin
            persistSession(session);
        end;
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
    function TCookieSessionManager.persistSession(const session : ISession) : ISessionManager;
    begin
        writeSessionFile(fCookieName, session.serialize());
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
    function TCookieSessionManager.destroySession(const session : ISession) : ISessionManager;
    begin
        session.clear();
        result := self;
    end;
end.

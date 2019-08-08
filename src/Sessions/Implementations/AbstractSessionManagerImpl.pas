{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit AbstractSessionManagerImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    SessionIntf,
    SessionIdGeneratorIntf,
    SessionManagerIntf,
    RequestIntf,
    InjectableObjectImpl;

type

    (*!------------------------------------------------
     * base abstract class having capability to manage
     * session variables
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TAbstractSessionManager = class(TInjectableObject, ISessionManager)
    protected

        fCookieName : string;
        fSessionIdGenerator : ISessionIdGenerator;

    public

        (*!------------------------------------
         * constructor
         *-------------------------------------
         * @param sessionIdGenerator helper class
         *           which can generate session id
         * @param cookieName name of cookie to use
         *-------------------------------------*)
        constructor create(
            const sessionIdGenerator : ISessionIdGenerator;
            const cookieName : string
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
        ) : ISession; virtual; abstract;

        (*!------------------------------------
         * end session and save session data to
         * persistent storage
         *-------------------------------------
         * @param session session instance
         * @return current instance
         *-------------------------------------*)
        function endSession(
            const session : ISession
        ) : ISessionManager; virtual; abstract;

        (*!------------------------------------
         * end session and remove its storage
         *-------------------------------------
         * @param session session instance
         * @return current instance
         *-------------------------------------*)
        function destroySession(
            const session : ISession
        ) : ISessionManager; virtual; abstract;
    end;

implementation

    (*!------------------------------------
     * constructor
     *-------------------------------------
     * @param baseDir base directory where
     *                session files store
     * @param prefix strung to be prefix to
     *                session filename
     *-------------------------------------*)
    constructor TAbstractSessionManager.create(
        const sessionIdGenerator : ISessionIdGenerator;
        const cookieName : string
    );
    begin
        inherited create();
        fSessionIdGenerator := sessionIdGenerator;
        fCookieName := cookieName;
    end;

    (*!------------------------------------
     * destructor
     *-------------------------------------*)
    destructor TAbstractSessionManager.destroy();
    begin
        inherited destroy();
        fSessionIdGenerator := nil;
    end;

end.

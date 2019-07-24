{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit SessionManagerIntf;

interface

{$MODE OBJFPC}
{$H+}

uses

    SessionIntf;

type

    (*!------------------------------------------------
     * interface for any class having capability to
     * create session from request
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    ISessionManager = interface
        ['{F6526BF2-538B-46CC-AF49-D5F373B6E2F5}']

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
        function beginSession(
            const sessionId : string;
            const lifeTimeInSec : integer;
        ) : ISession;

        (*!------------------------------------
         * end session and save session data to
         * persistent storage
         *-------------------------------------
         * @param session session instance
         * @return current instance
         *-------------------------------------*)
        function endSession(const session : ISession) : ISessionManager;
    end;

implementation
end.

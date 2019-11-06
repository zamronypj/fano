{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit IniSessionImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    Classes,
    IniFiles,
    SessionIntf;

type

    (*!------------------------------------------------
     * class having capability to manage
     * session variables in INI file
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TIniSession = class(TInterfacedObject, ISession)
    private
        fSessionName : shortstring;
        fSessionId : shortstring;
        fSessionData : TIniFile;
        fSessionStream : TStringStream;

        procedure raiseExceptionIfAlreadyTerminated();
        procedure raiseExceptionIfExpired();

        (*!------------------------------------
         * set session variable
         *-------------------------------------
         * @param sessionVar name of session variable
         * @param sessionVal value of session variable
         * @return current instance
         *-------------------------------------*)
        function internalSetVar(const sessionVar : shortstring; const sessionVal : string) : ISession;

        (*!------------------------------------
         * get session variable
         *-------------------------------------
         * @return session value
         *-------------------------------------*)
        function internalGetVar(const sessionVar : shortstring) : string;

        (*!------------------------------------
         * delete session variable
         *-------------------------------------
         * @param sessionVar name of session variable
         * @return current instance
         *-------------------------------------*)
        function internalDelete(const sessionVar : shortstring) : ISession;

        (*!------------------------------------
         * clear all session variables
         *-------------------------------------
         * This is only remove session data, but
         * underlying storage is kept
         *-------------------------------------
         * @return current instance
         *-------------------------------------*)
        function internalClear() : ISession;

        procedure cleanUp();
    public

        (*!------------------------------------
         * constructor
         *-------------------------------------
         * @param sessName session name
         * @param sessId session id
         * @param sessData session data
         *-------------------------------------*)
        constructor create(
            const sessName : shortstring;
            const sessId : shortstring;
            const sessData : string
        );

        destructor destroy(); override;

        (*!------------------------------------
         * get session name
         *-------------------------------------
         * @return session name
         *-------------------------------------*)
        function name() : shortstring;

        (*!------------------------------------
         * get current session id
         *-------------------------------------
         * @return session id string
         *-------------------------------------*)
        function id() : shortstring;

        (*!------------------------------------
         * get current session id
         *-------------------------------------
         * @return session id string
         *-------------------------------------*)
        function has(const sessionVar : shortstring) : boolean;

        (*!------------------------------------
         * set session variable
         *-------------------------------------
         * @param sessionVar name of session variable
         * @param sessionVal value of session variable
         * @return current instance
         *-------------------------------------*)
        function setVar(const sessionVar : shortstring; const sessionVal : string) : ISession; overload;

        (*!------------------------------------
         * set session variable
         *-------------------------------------
         * @param sessionVar name of session variable
         * @param sessionVal value of session variable
         *-------------------------------------*)
        procedure setVar(const sessionVar : shortstring; const sessionVal : string); overload;

        (*!------------------------------------
         * get session variable
         *-------------------------------------
         * @return session value
         *-------------------------------------*)
        function getVar(const sessionVar : shortstring) : string;

        (*!------------------------------------
         * delete session variable
         *-------------------------------------
         * @param sessionVar name of session variable
         * @return current instance
         *-------------------------------------*)
        function delete(const sessionVar : shortstring) : ISession;

        (*!------------------------------------
         * clear all session variables
         *-------------------------------------
         * This is only remove session data, but
         * underlying storage is kept
         *-------------------------------------
         * @return current instance
         *-------------------------------------*)
        function clear() : ISession;

        (*!------------------------------------
         * test if current session is expired
         *-------------------------------------
         * @return true if session is expired
         *-------------------------------------*)
        function expired() : boolean;

        (*!------------------------------------
         * get session expiration date
         *-------------------------------------
         * @return date time when session is expired
         *-------------------------------------*)
        function expiresAt() : TDateTime;

        (*!------------------------------------
         * serialize session data to string
         *-------------------------------------
         * @return string of session data
         *-------------------------------------*)
        function serialize() : string;
    end;

implementation

uses

    SysUtils,
    DateUtils,
    SessionConsts,
    ESessionExpiredImpl;

    (*!------------------------------------
     * constructor
     *-------------------------------------
     * @param sessName session name
     * @param sessId session id
     * @param sessData session data
     *-------------------------------------*)
    constructor TIniSession.create(
        const sessName : shortstring;
        const sessId : shortstring;
        const sessData : string
    );
    begin
        inherited create();
        fSessionName := sessName;
        fSessionId := sessId;
        fSessionStream := TStringStream.create(sessData);
        fSessionData := TIniFile.create(fSessionStream);
        raiseExceptionIfExpired();
    end;

    destructor TIniSession.destroy();
    begin
        cleanUp();
        inherited destroy();
    end;

    procedure TIniSession.cleanUp();
    begin
        fSessionStream.free();
        fSessionData.free();
    end;

    function TIniSession.name() : shortstring;
    begin
        result := fSessionName;
    end;

    (*!------------------------------------
     * get current session id
     *-------------------------------------
     * @return session id string
     *-------------------------------------*)
    function TIniSession.id() : shortstring;
    begin
        result := fSessionId;
    end;

    (*!------------------------------------
     * get current session id
     *-------------------------------------
     * @return session id string
     *-------------------------------------*)
    function TIniSession.has(const sessionVar : shortstring) : boolean;
    begin
        result := (fSessionData.readString('sessionVars', sessionVar, '') <> '');
    end;

    (*!------------------------------------
     * set session variable
     *-------------------------------------
     * @param sessionVar name of session variable
     * @param sessionVal value of session variable
     * @return current instance
     *-------------------------------------*)
    function TIniSession.internalSetVar(const sessionVar : shortstring; const sessionVal : string) : ISession;
    begin
        fSessionData.writeString('sessionVars', sessionVar, sessionVal);
        result := self;
    end;

    procedure TIniSession.raiseExceptionIfAlreadyTerminated();
    begin
        //TODO: raise ESessionTerminated.create()
    end;

    (*!------------------------------------
     * set session variable
     *-------------------------------------
     * @param sessionVar name of session variable
     * @param sessionVal value of session variable
     * @return current instance
     *-------------------------------------*)
    function TIniSession.setVar(const sessionVar : shortstring; const sessionVal : string) : ISession;
    begin
        raiseExceptionIfExpired();
        result := internalSetVar(sessionVar, sessionVal);
    end;

    (*!------------------------------------
     * get session variable
     *-------------------------------------
     * @return session value
     * @throws EJSON exception when not found
     *-------------------------------------*)
    function TIniSession.internalGetVar(const sessionVar : shortstring) : string;
    begin
        result := fSessionData.readString('sessionVars', sessionVar, '');
    end;

    (*!------------------------------------
     * get session variable
     *-------------------------------------
     * @return session value
     * @throws EJSON exception when not found
     *-------------------------------------*)
    function TIniSession.getVar(const sessionVar : shortstring) : string;
    begin
        raiseExceptionIfAlreadyTerminated();
        raiseExceptionIfExpired();
        result := internalGetVar(sessionVar);
    end;

    (*!------------------------------------
     * delete session variable
     *-------------------------------------
     * @param sessionVar name of session variable
     * @return current instance
     *-------------------------------------*)
    function TIniSession.internalDelete(const sessionVar : shortstring) : ISession;
    begin
        fSessionData.deleteKey('sessionVars', sessionVar);
        result := self;
    end;

    (*!------------------------------------
     * delete session variable
     *-------------------------------------
     * @param sessionVar name of session variable
     * @return current instance
     *-------------------------------------*)
    function TIniSession.delete(const sessionVar : shortstring) : ISession;
    begin
        raiseExceptionIfExpired();
        result := internalDelete(sessionVar);
    end;

    (*!------------------------------------
     * clear all session variables
     *-------------------------------------
     * This is only remove session data, but
     * underlying storage is kept
     *-------------------------------------
     * @return current instance
     *-------------------------------------*)
    function TIniSession.internalClear() : ISession;
    begin
        fSessionData.eraseSection('sessionVars');
        result := self;
    end;

    (*!------------------------------------
     * clear all session variables
     *-------------------------------------
     * This is only remove session data, but
     * underlying storage is kept
     *-------------------------------------
     * @return current instance
     *-------------------------------------*)
    function TIniSession.clear() : ISession;
    begin
        raiseExceptionIfExpired();
        result := internalClear();
    end;

    (*!------------------------------------
     * test if current session is expired
     *-------------------------------------
     * @return true if session is expired
     *-------------------------------------*)
    function TIniSession.expired() : boolean;
    var expiredDateTime : TDateTime;
    begin
        expiredDateTime := strToDateTime(fSessionData.readString('expiry', 'expire', '01-01-1970 00:00:00'));
        //value > 0, means now() is later than expiredDateTime i.e,
        //expireddateTime is in past
        result := (compareDateTime(now(), expiredDateTime) > 0);
    end;

    (*!------------------------------------
     * get expiration date
     *-------------------------------------
     * @return current session instance
     *-------------------------------------*)
    function TIniSession.expiresAt() : TDateTime;
    begin
        result := strToDateTime(fSessionData.readString('expiry', 'expire', '01-01-1970 00:00:00'));
    end;

    procedure TIniSession.raiseExceptionIfExpired();
    begin
        if (expired()) then
        begin
            raise ESessionExpired.createFmt(rsSessionExpired, [fSessionId]);
        end;
    end;

    (*!------------------------------------
     * serialize session data to string
     *-------------------------------------
     * @return string of session data
     *-------------------------------------*)
    function TIniSession.serialize() : string;
    begin
        fSessionData.updateFile();
        result := fSessionStream.dataString;
    end;
end.

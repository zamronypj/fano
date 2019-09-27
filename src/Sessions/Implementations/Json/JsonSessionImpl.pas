{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit JsonSessionImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    fpjson,
    SessionIntf;

type

    (*!------------------------------------------------
     * class having capability to manage
     * session variables in JSON file
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TJsonSession = class(TInterfacedObject, ISession)
    private
        fSessionName : shortstring;
        fSessionId : shortstring;
        fSessionData : TJsonData;

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
        function setVar(const sessionVar : shortstring; const sessionVal : string) : ISession;

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

    Classes,
    SysUtils,
    jsonParser,
    DateUtils,
    SessionConsts,
    ESessionExpiredImpl;

const

    SESSION_VARS = 'sessionVars';

    (*!------------------------------------
     * constructor
     *-------------------------------------
     * @param sessName session name
     * @param sessId session id
     * @param sessData session data
     *-------------------------------------*)
    constructor TJsonSession.create(
        const sessName : shortstring;
        const sessId : shortstring;
        const sessData : string
    );
    begin
        inherited create();
        fSessionName := sessName;
        fSessionId := sessId;
        fSessionData := getJSON(sessData);
        raiseExceptionIfExpired();
    end;

    destructor TJsonSession.destroy();
    begin
        cleanUp();
        inherited destroy();
    end;

    procedure TJsonSession.cleanUp();
    begin
        fSessionData.free();
    end;

    function TJsonSession.name() : shortstring;
    begin
        result := fSessionName;
    end;

    (*!------------------------------------
     * get current session id
     *-------------------------------------
     * @return session id string
     *-------------------------------------*)
    function TJsonSession.id() : shortstring;
    begin
        result := fSessionId;
    end;

    (*!------------------------------------
     * get current session id
     *-------------------------------------
     * @return session id string
     *-------------------------------------*)
    function TJsonSession.has(const sessionVar : shortstring) : boolean;
    begin
        result := (fSessionData.findPath(SESSION_VARS + '.' + sessionVar) <> nil);
    end;

    (*!------------------------------------
     * set session variable
     *-------------------------------------
     * @param sessionVar name of session variable
     * @param sessionVal value of session variable
     * @return current instance
     *-------------------------------------*)
    function TJsonSession.internalSetVar(const sessionVar : shortstring; const sessionVal : string) : ISession;
    var sessValue : TJsonData;
        tmpObj : TJsonObject;
    begin
        sessValue := fSessionData.findPath(SESSION_VARS + '.' + sessionVar);
        if (sessValue <> nil) then
        begin
            sessValue.asString := sessionVal;
        end else
        begin
            sessValue := fSessionData.findPath(SESSION_VARS);
            if (sessValue <> nil) then
            begin
                tmpObj := TJsonObject(sessValue);
            end else
            begin
                tmpObj := TJsonObject.create();
                TJsonObject(fSessionData).add(SESSION_VARS, tmpObj);
            end;
            tmpObj.add(sessionVar, sessionVal);
        end;
        result := self;
    end;

    procedure TJsonSession.raiseExceptionIfAlreadyTerminated();
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
    function TJsonSession.setVar(const sessionVar : shortstring; const sessionVal : string) : ISession;
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
    function TJsonSession.internalGetVar(const sessionVar : shortstring) : string;
    var sessValue : TJsonData;
    begin
        sessValue := fSessionData.getPath(SESSION_VARS + '.' + sessionVar);
        result := sessValue.asString;
    end;

    (*!------------------------------------
     * get session variable
     *-------------------------------------
     * @return session value
     * @throws EJSON exception when not found
     *-------------------------------------*)
    function TJsonSession.getVar(const sessionVar : shortstring) : string;
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
    function TJsonSession.internalDelete(const sessionVar : shortstring) : ISession;
    var sessValue : TJsonData;
    begin
        sessValue := fSessionData.findPath(SESSION_VARS);
        if (sessValue <> nil) then
        begin
            TJsonObject(sessValue).delete(sessionVar);
        end;
        result := self;
    end;

    (*!------------------------------------
     * delete session variable
     *-------------------------------------
     * @param sessionVar name of session variable
     * @return current instance
     *-------------------------------------*)
    function TJsonSession.delete(const sessionVar : shortstring) : ISession;
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
    function TJsonSession.internalClear() : ISession;
    var sessValue : TJsonData;
    begin
        sessValue := fSessionData.findPath(SESSION_VARS);
        if (sessValue <> nil) then
        begin
            sessValue.clear();
        end;
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
    function TJsonSession.clear() : ISession;
    begin
        raiseExceptionIfExpired();
        result := internalClear();
    end;

    (*!------------------------------------
     * test if current session is expired
     *-------------------------------------
     * @return true if session is expired
     *-------------------------------------*)
    function TJsonSession.expired() : boolean;
    var expiredDateTime : TDateTime;
    begin
        expiredDateTime := strToDateTime(fSessionData.getPath('expire').asString);
        //value > 0, means now() is later than expiredDateTime i.e,
        //expireddateTime is in past
        result := (compareDateTime(now(), expiredDateTime) > 0);
    end;

    (*!------------------------------------
     * set expiration date
     *-------------------------------------
     * @return current session instance
     *-------------------------------------*)
    function TJsonSession.expiresAt() : TDateTime;
    begin
        result := strToDateTime(fSessionData.getPath('expire').asString);
    end;

    procedure TJsonSession.raiseExceptionIfExpired();
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
    function TJsonSession.serialize() : string;
    begin
        result := fSessionData.asJSON;
    end;
end.

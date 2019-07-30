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
        fSessionId : string;
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
         * @param sessionId session id
         * @param sessionData session data
         *-------------------------------------*)
        constructor create(const sessionId : string; const sessionData : string);

        destructor destroy(); override;

        (*!------------------------------------
         * get current session id
         *-------------------------------------
         * @return session id string
         *-------------------------------------*)
        function id() : string;

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
    jsonParser,
    DateUtils,
    SessionConsts,
    ESessionExpiredImpl;

    (*!------------------------------------
     * constructor
     *-------------------------------------
     * @param sessionId session id
     * @param baseDir base directory where
     *                session files store
     * @param prefix strung to be prefix to
     *                session filename
     *-------------------------------------*)
    constructor TJsonSession.create(
        const sessionId : string;
        const sessionData : string
    );
    begin
        inherited create();
        fSessionId := sessionId;
        fSessionData := getJSON(sessionData);
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

    (*!------------------------------------
     * get current session id
     *-------------------------------------
     * @return session id string
     *-------------------------------------*)
    function TJsonSession.id() : string;
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
        result := (fSessionData.findPath('sessionVars.' + sessionVar) <> nil);
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
        sessValue := fSessionData.findPath('sessionVars.' + sessionVar);
        if (sessValue <> nil) then
        begin
            sessValue.asString := sessionVal;
        end else
        begin
            sessValue := fSessionData.findPath('sessionVars');
            if (sessValue <> nil) then
            begin
                tmpObj := TJsonObject(sessValue);
            end else
            begin
                tmpObj := TJsonObject.create();
                TJsonObject(fSessionData).add('sessionVars', tmpObj);
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
        sessValue := fSessionData.getPath('sessionVars.' + sessionVar);
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
        sessValue := fSessionData.getPath('sessionVars');
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
        sessValue := fSessionData.getPath('sessionVars');
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
        expiredDateTime := TDateTime(fSessionData.getPath('expire').asFloat);
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
    var sessData :TJsonObject;
        expiredDate : double;
    begin
        sessData := TJsonObject(fSessionData);
        expiredDate := sessData.floats['expire'].asFloat;
        result := TDateTime(expiredDate);
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

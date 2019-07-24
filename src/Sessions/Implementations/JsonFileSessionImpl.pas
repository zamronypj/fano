{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit JsonFileSessionImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    Classes,
    fpjson,
    SessionIntf;

type

    (*!------------------------------------------------
     * class having capability to manager
     * session variables in JSON file
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TJsonFileSession = class(TInterfacedObject, ISessionIntf)
    private
        fSessionId : string;
        fSessionFilename : string;
        fSessionData : TJsonData;

        function loadJsonFile(const jsonFile : string) : TJsonData;
        function loadOrCreateJsonFile(const jsonFile : string) : TJsonData;
        procedure writeJsonFile(const jsonFile : string; const jsonData : TJsonData);

        procedure raiseExceptionIfAlreadyTerminated();
        procedure raiseExceptionIfExpired();

        (*!------------------------------------
         * set session variable
         *-------------------------------------
         * @param sessionVar name of session variable
         * @param sessionVal value of session variable
         * @return current instance
         *-------------------------------------*)
        function internalSetVar(const sessionVar : shortstring; const sessionVal : string) : ISessionIntf;

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
        function internalDelete(const sessionVar : shortstring) : ISessionIntf;

        (*!------------------------------------
         * clear all session variables
         *-------------------------------------
         * This is only remove session data, but
         * underlying storage is kept
         *-------------------------------------
         * @return current instance
         *-------------------------------------*)
        function internalClear() : ISessionIntf;

        (*!------------------------------------
         * test if current session is expired
         *-------------------------------------
         * @return true if session is expired
         *-------------------------------------*)
        function internalExpired() : boolean;

        (*!------------------------------------
         * set expiration date
         *-------------------------------------
         * @return current session instance
         *-------------------------------------*)
        function internalExpiresAt(const expiredDate : TDateTime) : ISessionIntf;

        procedure cleanUp();
    public

        (*!------------------------------------
         * constructor
         *-------------------------------------
         * @param sessionId session id
         * @param baseDir base directory where
         *                session files store
         * @param prefix strung to be prefix to
         *                session filename
         *-------------------------------------*)
        constructor create(
            const sessionId : string;
            const baseDir : string;
            const prefix : string
        );

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
        function setVar(const sessionVar : shortstring; const sessionVal : string) : ISessionIntf;

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
        function delete(const sessionVar : shortstring) : ISessionIntf;

        (*!------------------------------------
         * clear all session variables
         *-------------------------------------
         * This is only remove session data, but
         * underlying storage is kept
         *-------------------------------------
         * @return current instance
         *-------------------------------------*)
        function clear() : ISessionIntf;

        (*!------------------------------------
         * terminate session and remove underlying storage
         * (if any)
         *-------------------------------------
         * @return current instance
         *-------------------------------------*)
        function terminate() : ISessionIntf;

        (*!------------------------------------
         * test if current session is expired
         *-------------------------------------
         * @return true if session is expired
         *-------------------------------------*)
        function expired() : boolean;

        (*!------------------------------------
         * set expiration date
         *-------------------------------------
         * @return current session instance
         *-------------------------------------*)
        function expiresAt(const expiredDate : TDateTime) : ISessionIntf;
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
    constructor TJsonFileSession.create(
        const sessionId : string;
        const baseDir : string;
        const prefix : string
    );
    begin
        inherited create();
        fSessionId := sessionId;
        fSessionFilename := baseDir + prefix + sessionId;
        fSessionData := loadOrCreateJsonFile(fSessionFilename);
        //no whitespace to reduce json file size
        fSessionData.compressedJSON := true;
        raiseExceptionIfExpired();
    end;

    destructor TJsonFileSession.destroy();
    begin
        cleanUp();
        inherited destroy();
    end;

    procedure TJsonFileSession.cleanUp();
    begin
        if (expired()) then
        begin
            terminate();
        end else
        begin
            writeJsonFile(fSessionFilename, fSessionData);
            fSessionData.free();
        end;
    end;

    function TJsonFileSession.loadJsonFile(const jsonFile : string; const mode :word) : TJsonData;
    var fs : TFileStream;
    begin
        fs := TFileStream.create(jsonFile, mode);
        try
            result := getJSON(fs);
        finally
            fs.free();
        end;
    end;

    function TJsonFileSession.loadOrCreateJsonFile(const jsonFile : string) : TJsonData;
    var mode : word;
    begin
        if (fileExists(jsonFile)) then
        begin
            mode := fmOpenRead;
        end else
        begin
            mode := fmCreate;
        end;
        result := loadJsonFile(jsonFile, mode);
    end;

    procedure TJsonFileSession.writeJsonFile(const jsonFile : string; const jsonData : TJsonData);
    var fs : TFileStream;
    begin
        fs := TFileStream.create(jsonFile, fmCreate);
        try
            fSessionData.dumpJSON(fs);
        finally
            fs.free();
        end;
    end;

    (*!------------------------------------
     * get current session id
     *-------------------------------------
     * @return session id string
     *-------------------------------------*)
    function TJsonFileSession.id() : string;
    begin
        result := fSessionId;
    end;

    (*!------------------------------------
     * get current session id
     *-------------------------------------
     * @return session id string
     *-------------------------------------*)
    function TJsonFileSession.has(const sessionVar : shortstring) : boolean;
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
    function TJsonFileSession.internalSetVar(const sessionVar : shortstring; const sessionVal : string) : ISessionIntf;
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

    (*!------------------------------------
     * set session variable
     *-------------------------------------
     * @param sessionVar name of session variable
     * @param sessionVal value of session variable
     * @return current instance
     *-------------------------------------*)
    function TJsonFileSession.setVar(const sessionVar : shortstring; const sessionVal : string) : ISessionIntf;
    begin
        raiseExceptionIfAlreadyTerminated();
        raiseExceptionIfExpired();
        result := internalSetVar(sessionVar, sessionVal);
    end;

    (*!------------------------------------
     * get session variable
     *-------------------------------------
     * @return session value
     * @throws EJSON exception when not found
     *-------------------------------------*)
    function TJsonFileSession.internalGetVar(const sessionVar : shortstring) : string;
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
    function TJsonFileSession.getVar(const sessionVar : shortstring) : string;
    begin
        raiseExceptionIfAlreadyTerminated();
        raiseExceptionIfExpired();
        result := internalGetVar(sessionVar, sessionVal);
    end;

    (*!------------------------------------
     * delete session variable
     *-------------------------------------
     * @param sessionVar name of session variable
     * @return current instance
     *-------------------------------------*)
    function TJsonFileSession.internalDelete(const sessionVar : shortstring) : ISessionIntf;
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
    function TJsonFileSession.delete(const sessionVar : shortstring) : ISessionIntf;
    begin
        raiseExceptionIfAlreadyTerminated();
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
    function TJsonFileSession.internalClear() : ISessionIntf;
    begin
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
    function TJsonFileSession.clear() : ISessionIntf;
    begin
        raiseExceptionIfAlreadyTerminated();
        raiseExceptionIfExpired();
        result := internalClear();
    end;

    (*!------------------------------------
     * terminate session and remove underlying storage
     * (if any)
     *-------------------------------------
     * @return current instance
     *-------------------------------------*)
    function TJsonFileSession.terminate() : ISessionIntf;
    begin
        freeAndNil(fSessionData);
        if (fileExists(fSessionFilename)) then
        begin
            deleteFile(fSessionFilename);
        end;
    end;

    (*!------------------------------------
     * test if current session is expired
     *-------------------------------------
     * @return true if session is expired
     *-------------------------------------*)
    function TJsonFileSession.internalExpired() : boolean;
    var expiredDateTime : TDateTime;
    begin
        expiredDateTime := TDateTime(fSessionData.getPath('expire').asFloat);
        //value > 0, means now() is later than expiredDateTime i.e,
        //expireddateTime is in past
        result (compareDateTime(now(), expiredDateTime) > 0);
    end;

    (*!------------------------------------
     * test if current session is expired
     *-------------------------------------
     * @return true if session is expired
     *-------------------------------------*)
    function TJsonFileSession.expired() : boolean;
    begin
        raiseExceptionIfAlreadyTerminated();
        result := internalExpired();
    end;

    (*!------------------------------------
     * set expiration date
     *-------------------------------------
     * @return current session instance
     *-------------------------------------*)
    function TJsonFileSession.internalExpiresAt(const expiredDate : TDateTime) : ISessionIntf;
    var sessData :TJsonObject;
    begin
        sessData := TJsonObject(fSessionData);
        sessData.floats['expire'].asFloat := TJsonFloat(expiredDate);
        result := self;
    end;

    (*!------------------------------------
     * set expiration date
     *-------------------------------------
     * @return current session instance
     *-------------------------------------*)
    function TJsonFileSession.expiresAt(const expiredDate : TDateTime) : ISessionIntf;
    begin
        raiseExceptionIfAlreadyTerminated();
        result := internalExpiresAt(expiredDate);
    end;

    procedure TJsonFileSession.raiseExceptionIfExpired();
    begin
        if (expired()) then
        begin
            terminate();
            raise ESessionExpired.create(rsSessionExpired);
        end;
    end;

    procedure TJsonFileSession.raiseExceptionIfAlreadyTerminated();
    begin
        if (fSessionData = nil) then
        begin
            raise ESessionInvalid.create(rsSessionInvalid);
        end;
    end;
end.

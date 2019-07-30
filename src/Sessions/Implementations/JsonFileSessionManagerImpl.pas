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
    SessionManagerIntf;

type

    (*!------------------------------------------------
     * class having capability to manager
     * session variables in JSON file
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TJsonFileSessionManager = class(TInterfacedObject, ISessionManager)
    private
        fSessionFilename : string;
        fSessionIdGenerator : ISessionIdGenerator;

        function loadJsonFile(const jsonFile : string; const mode :word) : string;
        function loadOrCreateJsonFile(const jsonFile : string) : string;
        procedure writeJsonFile(const jsonFile : string; const jsonData : TJsonData);
        function loadStreamAsString(const stream : TStream) : string;

        procedure raiseExceptionIfAlreadyTerminated();
        procedure raiseExceptionIfExpired();

    public

        (*!------------------------------------
         * constructor
         *-------------------------------------
         * @param baseDir base directory where
         *                session files store
         * @param prefix string to be prefix to
         *                session filename
         *-------------------------------------*)
        constructor create(
            const sessionIdGenerator : ISessionIdGenerator;
            const baseDir : string;
            const prefix : string
        );

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
            const lifeTimeInSec : integer
        ) : ISession;

        (*!------------------------------------
         * end session and save session data to
         * persistent storage
         *-------------------------------------
         * @param session session instance
         * @return current instance
         *-------------------------------------*)
        function endSession(const session : ISession) : ISessionManager;

        (*!------------------------------------
         * end session and remove its storage
         *-------------------------------------
         * @param session session instance
         * @return current instance
         *-------------------------------------*)
        function destroySession(const session : ISession) : ISessionManager;
    end;

implementation

uses

    jsonParser,
    DateUtils,
    SessionConsts,
    ESessionExpiredImpl;

    (*!------------------------------------
     * constructor
     *-------------------------------------
     * @param baseDir base directory where
     *                session files store
     * @param prefix strung to be prefix to
     *                session filename
     *-------------------------------------*)
    constructor TJsonFileSessionManager.create(
        const sessionIdGenerator : ISessionIdGenerator;
        const baseDir : string;
        const prefix : string
    );
    begin
        inherited create();
        fSessionIdGenerator := sessionIdGenerator;
        fSessionFilename := baseDir + prefix;
    end;

    function TJsonFileSessionManager.loadStreamAsString(const stream : TStream) : string;
    var strStream : TStringStream;
    begin
        strStream := TStringStream.create('');
        try
            stream.seek(0, soFromBeginning);
            strStream.copyFrom(stream, 0);
            result := strStream.dataString;
        finally
            strStream.free();
        end;
    end;

    function TJsonFileSessionManager.loadJsonFile(const jsonFile : string; const mode :word) : string;
    var fs : TFileStream;
    begin
        fs := TFileStream.create(jsonFile, mode);
        try
            result := loadStreamAsString(fs);
        finally
            fs.free();
        end;
    end;

    function TJsonFileSessionManager.loadOrCreateJsonFile(const jsonFile : string) : string;
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

    procedure TJsonFileSessionManager.writeJsonFile(const jsonFile : string; const jsonData : string);
    var fs : TFileStream;
    begin
        fs := TFileStream.create(jsonFile, fmCreate);
        try
            fs.seek(0, soFromBeginning);
            fs.writeBuffer(jsonData[0], length(jsonData));
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
    function beginSession(
        const sessionId : string;
        const lifeTimeInSec : integer
    ) : ISession;
    var sess : ISession;
        sessFile : string;
        expiredDate : TDateTime;
    begin
        sess := nil;
        sessFile := fSessionFilename + sessionId;
        if fileExists(sessFile) then
        begin
            sess := TJsonSession.create(sessionId, loadFileToString(sessFile));
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
                    [ dateTimeToStr(expiredDate) ]
                )
            );
        end;
        result := sess;
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
        writeToFile(sessFilename, session.serialize());
        session.clear();
    end;

    (*!------------------------------------
     * end session and save session data to
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
    end;
end.

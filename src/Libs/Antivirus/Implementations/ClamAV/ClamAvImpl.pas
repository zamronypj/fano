{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ClamAvImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    AntivirusIntf,
    ScanResultIntf;

type

    (*!-----------------------------------------------
     * class having capability to scan file for computer virus
     * using ClamAV antivirus. This class is used for
     * validating file upload.
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TClamAv = class(TInterfacedObject, IAntivirus, IScanResult)
    private
        fVirusName : PAnsiChar;
        fCleaned : boolean;
        fEngineCreated : boolean;
        fEngine : pointer;
        procedure loadAntivirusDb(const engine : pointer);
        procedure compileEngine(var engine : pointer);
        procedure raiseExceptionIfFailed(const errCode : integer; const msg : string);
        procedure createEngine(var engine : pointer);
        procedure freeEngine(var engine : pointer);
    public
        constructor create();
        destructor destroy(); override;

        (*!------------------------------------------------
         * setup antivirus engine
         *-----------------------------------------------
         * @return current instance
         *-----------------------------------------------*)
        function beginScan() : IAntivirus;

        (*!------------------------------------------------
         * scan file for virus
         *-----------------------------------------------
         * @return scan result
         *-----------------------------------------------*)
        function scanFile(const filePath : string) : IScanResult;

        (*!------------------------------------------------
         * free antivirus engine resources
         *-----------------------------------------------
         * @return current instance
         *-----------------------------------------------*)
        function endScan() : IAntivirus;

        (*!------------------------------------------------
         * test if the last scan is cleaned
         *-----------------------------------------------
         * @return true if cleaned
         *-----------------------------------------------*)
        function isCleaned() : boolean;

        (*!------------------------------------------------
         * return name of virus if virus detected
         *------------------------------------------------
         * @return name of virus or empty string if clean
         *-----------------------------------------------*)
        function virusName() : string;

    end;

implementation

uses

    clamav3,
    EClamAvImpl;

    procedure TClamAv.raiseExceptionIfFailed(const errCode : integer; const msg : string);
    begin
        if (errCode <> CL_SUCCESS) then
        begin
            freeEngine(fEngine);
            raise EClamAv.create(msg + AnsiString(cl_strerror(errCode)));
        end;
    end;

    constructor TClamAv.create();
    var ret : integer;
    begin
        fCleaned := false;
        fVirusName := nil;
        fEngineCreated := false;
        fEngine := nil;
        ret := cl_init(CL_INIT_DEFAULT);
        raiseExceptionIfFailed(ret, 'ClamAV initialization fails. ');
    end;

    destructor TClamAv.destroy();
    begin
        endScan();
        inherited destroy();
    end;

    procedure TClamAv.loadAntivirusDb(const engine : pointer);
    var ret : integer;
        sigs : cardinal;
    begin
        ret := cl_load(cl_retdbdir(), cl_engine(engine^), sigs, CL_DB_STDOPT);
        raiseExceptionIfFailed(ret, 'Load antivirus database fails. ');
    end;

    procedure TClamAv.createEngine(var engine : pointer);
    begin
        engine := cl_engine_new();
        if (engine <> nil) then
        begin
            raise EClamAv.create('Engine creation failed.');
        end;
    end;

    procedure TClamAv.freeEngine(var engine : pointer);
    begin
        if fEngineCreated then
        begin
            cl_engine_free(cl_engine(engine^));
            engine := nil;
            fEngineCreated := false;
        end;
    end;

    procedure TClamAv.compileEngine(var engine : pointer);
    var ret : integer;
    begin
        ret := cl_engine_compile(cl_engine(engine^));
        raiseExceptionIfFailed(ret, 'Compile engine failed. ');
    end;

    (*!------------------------------------------------
        * setup antivirus engine
        *-----------------------------------------------
        * @return current instance
        *-----------------------------------------------*)
    function TClamAv.beginScan() : IAntivirus;
    begin
        if (not fEngineCreated) then
        begin
            createEngine(fEngine);
            loadAntivirusDb(fEngine);
            compileEngine(fEngine);
            fEngineCreated := (fEngine <> nil);
        end;
        result := self;
    end;

    (*!------------------------------------------------
        * free antivirus engine resources
        *-----------------------------------------------
        * @return current instance
        *-----------------------------------------------*)
    function TClamAv.endScan() : IAntivirus;
    begin
        freeEngine(fEngine);
        result := self;
    end;

    (*!------------------------------------------------
        * scan file for virus
        *-----------------------------------------------
        * @return scan result
        *-----------------------------------------------*)
    function TClamAv.scanFile(const filePath : string) : IScanResult;
    var ret : longint;
        scanned : dword;
    begin
        scanned := 0;
        ret := cl_scanfile(
            PChar(filePath),
            @fVirusName,
            scanned,
            cl_engine(fEngine^),
            dword(CL_SCAN_STDOPT)
        );
        fCleaned := (ret = CL_CLEAN) or (ret = CL_SUCCESS);
        result := self;
    end;

    (*!------------------------------------------------
     * test if the last scan is cleaned
     *-----------------------------------------------
     * @return true if cleaned
     *-----------------------------------------------*)
    function TClamAv.isCleaned() : boolean;
    begin
        result := fCleaned;
    end;

    (*!------------------------------------------------
     * return name of virus if virus detected
     *------------------------------------------------
     * @return name of virus or empty string if clean
     *-----------------------------------------------*)
    function TClamAv.virusName() : string;
    begin
        result := AnsiString(fVirusName);
    end;

end.

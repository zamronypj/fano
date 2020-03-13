{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit AbstractClamdAvImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    ssockets,
    AntivirusIntf,
    ScanResultIntf;

type

    (*!-----------------------------------------------
     * abstract class having capability to scan file for computer virus using
     * ClamAV daemon server over TCP socket. This is to validate uploaded file
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TAbstractClamdAv = class abstract (TInterfacedObject, IAntivirus, IScanResult)
    private
        fUseUnixDomainSocket : boolean;
        fUnixSock : string;
        fHost : string;
        fPort : word;
        fClean : boolean;
        fVirusName : string;
        function sendScanRequest(const filePath : string) : string;
    protected
        procedure raiseSockReadExcept();
        function doSendScanRequest(
            const socket : TSocketStream;
            const filePath : string
        ) : string; virtual; abstract;

    public

        (*!------------------------------------------------
         * constructor
         *-----------------------------------------------
         * @param host hostname or ip where clamav daemon listen
         * @param port port where clamav daemon listen
         *-----------------------------------------------*)
        constructor create(const host : string; const port : word); overload;

        (*!------------------------------------------------
         * constructor
         *-----------------------------------------------
         * @param unixSock unix domain socket file where daemon listen
         *-----------------------------------------------*)
        constructor create(const unixSock : string); overload;

        (*!------------------------------------------------
         * setup antivirus engine
         *-----------------------------------------------
         * @return current instance
         *-----------------------------------------------*)
        function beginScan() : IAntivirus;

        (*!------------------------------------------------
         * scan file for virus
         *-----------------------------------------------
         * @param filepath absolute path of file need to be scanned
         * @return scan result
         *-----------------------------------------------
         * For example if filepath is /path/to/file
         *
         * On clean scan, clamav daemon returns string
         * /path/to/file: OK
         *
         * On infected, clamav daemon returns string
         * /path/to/file: virusName FOUND
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

    sockets,
    errors,
    strutils,
    SocketConsts,
    ESockErrorImpl;

    constructor TAbstractClamdAv.create(const host : string; const port : word);
    begin
        fHost := host;
        fPort := port;
        fUseUnixDomainSocket := false;
    end;

    constructor TAbstractClamdAv.create(const unixSock : string);
    begin
        fUnixSock := unixSock;
        fUseUnixDomainSocket := true;
    end;

    (*!------------------------------------------------
     * setup antivirus engine
     *-----------------------------------------------
     * @return current instance
     *-----------------------------------------------*)
    function TAbstractClamdAv.beginScan() : IAntivirus;
    begin
        //intentionally does nothing
        result := self;
    end;

    (*!------------------------------------------------
     * free antivirus engine resources
     *-----------------------------------------------
     * @return current instance
     *-----------------------------------------------*)
    function TAbstractClamdAv.endScan() : IAntivirus;
    begin
        //intentionally does nothing
        result := self;
    end;

    function TAbstractClamdAv.sendScanRequest(const filePath : string) : string;
    var
        socket : TSocketStream;
    begin
        if fUseUnixDomainSocket then
        begin
            socket := TUnixSocket.create(fUnixSock);
        end else
        begin
            socket := TInetSocket.create(fHost, fPort);
        end;

        try
            result := doSendScanRequest(socket, filePath);
        finally
            socket.free();
        end;
    end;


    (*!------------------------------------------------
     * scan file for virus
     *-----------------------------------------------
     * @param filepath absolute path of file need to be scanned
     * @return scan result
     *-----------------------------------------------
     * For example if filepath is /path/to/file
     *
     * On clean scan, clamav daemon returns string
     * /path/to/file: OK
     *
     * On infected, clamav daemon returns string
     * /path/to/file: virusName FOUND
     *-----------------------------------------------*)
    function TAbstractClamdAv.scanFile(const filePath : string) : IScanResult;
    var
        response : string;
        scanStatusPos : integer;
        lenFilePath : integer;
    begin
        fVirusName := '';
        response := sendScanRequest(filePath);
        scanStatusPos := rpos('OK', response);
        fClean := (scanStatusPos <> 0);
        if not fClean then
        begin
            //length of filepath + ': '
            lenFilePath := length(filePath) + 2;
            scanStatusPos := rpos(' FOUND', response);
            fVirusName := copy(response, lenFilePath + 1, scanStatusPos - lenFilePath);
        end;
        result := self;
    end;

    (*!------------------------------------------------
     * test if the last scan is cleaned
     *-----------------------------------------------
     * @return true if cleaned
     *-----------------------------------------------*)
    function TAbstractClamdAv.isCleaned() : boolean;
    begin
        //intentionally does nothing and always assumed cleaned
        result := fClean;
    end;

    (*!------------------------------------------------
     * return name of virus if virus detected
     *------------------------------------------------
     * @return name of virus or empty string if clean
     *-----------------------------------------------*)
    function TAbstractClamdAv.virusName() : string;
    begin
        result := fVirusName;
    end;

    procedure TAbstractClamdAv.raiseSockReadExcept();
    var
        errCode : longint;
    begin
        errCode := socketError();
        raise ESockError.createFmt(rsSocketReadFailed, errCode, strError(errCode));
    end;

end.

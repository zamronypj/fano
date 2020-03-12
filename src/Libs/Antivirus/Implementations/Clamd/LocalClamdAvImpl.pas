{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit LocalClamdAvImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    AntivirusIntf,
    ScanResultIntf;

type

    (*!-----------------------------------------------
     * class having capability to scan file for computer virus using
     * ClamAV daemon server over TCP socket. This is to validate uploaded file
     * This assumes that clamav daemon is run in the same machine as
     * our application, thus it has access to file content directly
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TLocalClamdAv = class(TInterfacedObject, IAntivirus, IScanResult)
    private
        fUseUnixDomainSocket : boolean;
        fUnixSock : string;
        fHost : string;
        fPort : word;
        fClean : boolean;
        fVirusName : string;
        function sendScanRequest(const filePath : string) : string;
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

    strutils,
    ssockets;

    constructor TLocalClamdAv.create(const host : string; const port : word);
    begin
        fHost := host;
        fPort := port;
        fUseUnixDomainSocket := false;
    end;

    constructor TLocalClamdAv.create(const unixSock : string);
    begin
        fUnixSock := unixSock;
        fUseUnixDomainSocket := true;
    end;

    (*!------------------------------------------------
     * setup antivirus engine
     *-----------------------------------------------
     * @return current instance
     *-----------------------------------------------*)
    function TLocalClamdAv.beginScan() : IAntivirus;
    begin
        //intentionally does nothing
        result := self;
    end;

    (*!------------------------------------------------
     * free antivirus engine resources
     *-----------------------------------------------
     * @return current instance
     *-----------------------------------------------*)
    function TLocalClamdAv.endScan() : IAntivirus;
    begin
        //intentionally does nothing
        result := self;
    end;

    function TLocalClamdAv.sendScanRequest(const filePath : string) : string;
    var socket : TSocketStream;
        command : string;
        buff : string;
        buffRead : integer;
    begin
        if fUseUnixDomainSocket then
        begin
            socket := TUnixSocket.create(fUnixSock);
        end else
        begin
            socket := TInetSocket.create(fHost, fPort);
        end;

        try
            result := '';
            command := 'nSCAN ' + filePath + #10;
            socket.writeBuffer(command, length(command));
            setLength(buff, 4096);
            repeat
                buffRead := socket.read(buff[1], 4096);
                if buffRead > 0 then
                begin
                    result := result + copy(buff[1], 1, buffRead);
                end;
            until (buffRead > 0);
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
    function TLocalClamdAv.scanFile(const filePath : string) : IScanResult;
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
    function TLocalClamdAv.isCleaned() : boolean;
    begin
        //intentionally does nothing and always assumed cleaned
        result := fClean;
    end;

    (*!------------------------------------------------
     * return name of virus if virus detected
     *------------------------------------------------
     * @return name of virus or empty string if clean
     *-----------------------------------------------*)
    function TLocalClamdAv.virusName() : string;
    begin
        result := fVirusName;
    end;

end.

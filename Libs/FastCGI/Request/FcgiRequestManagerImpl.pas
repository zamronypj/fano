{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FcgiRequestManagerImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    EnvironmentIntf,
    FcgiRecordIntf,
    StreamAdapterIntf,
    FcgiRequestManagerIntf;

type

    TRequestRecord = record
        used : boolean;
        //store FCGI_STDIN stream completeness
        fcgiStdInComplete : boolean;
        //store FCGI_PARAMS stream completeness
        fcgiParamsComplete : boolean;
        fcgiRecords : array of IFcgiRecord;

        stdInStream : IStreamAdapter;
        env : ICGIEnvironment;
    end;

    TRequestRecordArr = array of TRequestRecord;

    (*!-----------------------------------------------
     * Basic class having capability to manage
     * FastCGI requests multiplexing
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiRequestManager = class(TInterfacedObject, IFcgiRequestManager)
    private
        fRecords : TRequestRecordArr;

        procedure initRecords();
        procedure initSingleRecord(const requestId : word);
        procedure clearRecords();

        (*!------------------------------------------------
         * get data from all records identified by request id and type
         *-----------------------------------------------
         * @param requestId, request id
         * @param atype, record type
         * @return stream instance of all records identified by type
         *-----------------------------------------------*)
        function getStreamByType(const requestId : word; const atyp: byte) : IStreamAdapter;

        (*!------------------------------------------------
         * mark request completeness
         *-----------------------------------------------
         * @param rec, record to check
         * @return true if request identified by id is complete
         *-----------------------------------------------*)
        procedure markCompleteness(const rec : IFcgiRecord);

        (*!------------------------------------------------
         * initialize get CGI Environment for request identified by request id
         *-----------------------------------------------
         * @param requestId, request id
         * @return CGI environment
         *-----------------------------------------------*)
        function initEnvironment(const requestId : word) : ICGIEnvironment;

    public

        (*!------------------------------------------------
         * constructor
         *-----------------------------------------------
         * @param initialCapacity, initial pre allocated array
         *-----------------------------------------------*)
        constructor create(const initialCapacity : integer = 32);

        (*!------------------------------------------------
         * destructor
         *-----------------------------------------------*)
        destructor destroy(); override;

        (*!------------------------------------------------
         * test if request identified by id exist
         *-----------------------------------------------
         * @param requestId, request id to check
         * @return true if request identified by id exist
         *-----------------------------------------------*)
        function has(const requestId : word) : boolean;

        (*!------------------------------------------------
         * test if web server is done sending request
         * to us identified by id
         *-----------------------------------------------
         * @param requestId, request id to check
         * @return true if request identified by id is complete
         *-----------------------------------------------*)
        function complete(const requestId : word) : boolean;

        (*!------------------------------------------------
         * get data from all FCGI_STDIN identified by request id
         *-----------------------------------------------
         * @param requestId, request id
         * @return stream instance of all FCGI_STDIN records
         *-----------------------------------------------*)
        function getStdInStream(const requestId : word) : IStreamAdapter;

        (*!------------------------------------------------
         * get CGI Environment for request identified by request id
         *-----------------------------------------------
         * @param requestId, request id
         * @return CGI environment or nil if environment not ready
         *-----------------------------------------------*)
        function getEnvironment(const requestId : word) : ICGIEnvironment;

        (*!------------------------------------------------
         * add FastCGI record to manager
         *-----------------------------------------------
         * @param rec, FastCGI record to add
         * @return id of current request
         *-----------------------------------------------*)
        function add(const rec : IFcgiRecord) : IFcgiRequestManager;

        (*!------------------------------------------------
         * remove request
         *-----------------------------------------------
         * @param requestId, request id to be removed
         * @return true of request is removed
         *-----------------------------------------------*)
        function remove(const requestId : word) : boolean;
    end;

implementation

uses

    fastcgi,
    StreamAdapterCollectionImpl;

    (*!------------------------------------------------
     * constructor
     *-----------------------------------------------
     * @param initialCapacity, initial pre allocated array
     *-----------------------------------------------*)
    constructor TFcgiRequestManager.create(const initialCapacity : integer = 32);
    begin
        setLength(fRecords, initialCapacity);
        initRecords();
    end;

    (*!------------------------------------------------
     * destructor
     *-----------------------------------------------*)
    destructor TFcgiRequestManager.destroy();
    begin
        inherited destroy();
        clearRecords();
        setLength(fRecords, 0);
    end;

    procedure TFcgiRequestManager.initRecords();
    var i : integer;
    begin
        for i := length(fRecords) - 1 downto 0 do
        begin
            initSingleRecord(i);
        end;
    end;

    procedure TFcgiRequestManager.initSingleRecord(const requestId : word);
    begin
        fRecords[requestId].used := false;
        fRecords[requestId].fcgiStdInComplete := false;
        fRecords[requestId].fcgiParamsComplete := false;
        fRecords[requestId].env := nil;
        fRecords[requestId].stdInStream := nil;
        setLength(fRecords[requestId].fcgiRecords, 0);
    end;

    procedure TFcgiRequestManager.clearRecords();
    var i, j: integer;
    begin
        for i := length(fRecords) - 1 downto 0 do
        begin
            for j := length(fRecords[i].fcgiRecords) - 1 downto 0 do
            begin
                fRecords[i].fcgiRecords[j] := nil;
            end;
            setLength(fRecords[i].fcgiRecords, 0);
        end;
    end;

    (*!------------------------------------------------
     * test if request identified by id exist
     *-----------------------------------------------
     * @param requestId, request id to check
     * @return true if request identified by id exist
     *-----------------------------------------------*)
    function TFcgiRequestManager.has(const requestId : word) : boolean;
    begin
        result := (requestId < length(fRecords)) and fRecords[requestId].used;
    end;

    (*!------------------------------------------------
     * test if web server is done sending request
     * to us identified by id
     *-----------------------------------------------
     * @param requestId, request id to check
     * @return true if request identified by id is complete
     *-----------------------------------------------*)
    function TFcgiRequestManager.complete(const requestId : word) : boolean;
    begin
        result := fRecords[requestId].fcgiStdInComplete and
            fRecords[requestId].fcgiParamsComplete;
    end;

    (*!------------------------------------------------
     * get data from all records identified by request id and type
     *-----------------------------------------------
     * @param requestId, request id
     * @param atype, record type
     * @return stream instance of all records identified by type
     *-----------------------------------------------*)
    function TFcgiRequestManager.getStreamByType(const requestId : word; const atyp: byte) : IStreamAdapter;
    var coll : IStreamAdapterCollection;
        i, len : integer;
        rec : IFcgiRecord;
    begin
        coll := fStreamCollectionFactory.build();
        len := length(fRecords[requestId].fcgiRecords);
        for i := 0 to len - 1 do
        begin
            rec := fRecords[requestId].fcgiRecords[i];
            if (assigned(rec) and rec.getType() = atype) then
            begin
                //add its stream to collection
                coll.add(rec.data());
            end;
        end;

        result := coll as IStreamAdapter;
    end;

    (*!------------------------------------------------
     * get data from all FCGI_STDIN identified by request id
     *-----------------------------------------------
     * @param requestId, request id
     * @return stream instance of all FCGI_STDIN records
     *-----------------------------------------------*)
    function TFcgiRequestManager.getStdInStream(const requestId : word) : IStreamAdapter;
    begin
        result := fRecords[requestId].stdInStream;
    end;

    (*!------------------------------------------------
     * initialize CGI Environment for request identified by request id
     *-----------------------------------------------
     * @param requestId, request id
     * @return CGI environment
     *-----------------------------------------------*)
    function TFcgiRequestManager.initEnvironment(const requestId : word) : ICGIEnvironment;
    var paramStream : IStreamAdapter;
        factory : ICGIEnvironmentFactory;
    begin
        //get all FCGI_PARAMS records stream as one big stream
        paramStream := getStreamByType(requestId, FCGI_PARAMS);
        factory := TFCGIEnvironmentFactory.create(paramStream);
        result := factory.build();
    end;

    (*!------------------------------------------------
     * get CGI Environment for request identified by request id
     *-----------------------------------------------
     * @param requestId, request id
     * @return CGI environment or nil if environment not ready
     *-----------------------------------------------*)
    function TFcgiRequestManager.getEnvironment(const requestId : word) : ICGIEnvironment;
    begin
        result := fRecords[requestId].env;
    end;

    (*!------------------------------------------------
     * mark request completeness
     *-----------------------------------------------
     * @param rec, record to check
     * @return true if request identified by id is complete
     *-----------------------------------------------*)
    procedure TFcgiRequestManager.markCompleteness(const rec : IFcgiRecord);
    var recType : byte;
        requestId : word;
    begin
        recType := rec.getType();
        if (recType = FCGI_BEGIN_REQUEST) then
        begin
            fRecords[requestId].fcgiStdInComplete := false;
            fRecords[requestId].fcgiParamsComplete := false;
        end;

        //if we received FCGI_PARAMS with empty data, it means web server complete
        //sending FCGI_PARAMS request data.
        if (recType = FCGI_PARAMS) and (rec.getContentLength() = 0) then
        begin
            fRecords[requestId].fcgiParamsComplete := true;
        end;

        //if we received FCGI_STDIN with empty data, it means web server complete
        //sending FCGI_STDIN request data.
        if (recType = FCGI_STDIN) and (rec.getContentLength() = 0) then
        begin
            fRecords[requestId].fcgiStdInComplete := true;
        end;

        if (complete(requestId)) then
        begin
            fRecords[requestId].env := initEnvironment(requestId);
            fRecords[requestId].stdInStream := getStreamByType(requestId, FCGI_STDIN);
        end;
    end;

    (*!------------------------------------------------
     * add FastCGI record to manager
     *-----------------------------------------------
     * @param rec, FastCGI record to add
     * @return id of current request
     *-----------------------------------------------*)
    function TFcgiRequestManager.add(const rec : IFcgiRecord) : IFcgiRequestManager;
    var requestId : word;
        totalRecord : integer;
    begin
        requestId := rec.getRequestId();
        //if we received FCGI_BEGIN_REQUEST, do some test
        if (rec.getType() = FCGI_BEGIN_REQUEST) and has(requestId) then
        begin
            //something is very wrong, requestId must not exists when
            //begin request
            raise EInvalidFcgiRequestId.createFmt('Invalid request id %d', [requesId]);
        end;

        if (has(requestId)) then
        begin
            totalRecord := length(fRecords[requestId].fcgiRecords);
            setLength(fRecords[requestId].fcgiRecords, totalRecord + 1);
            fRecords[requestId].fcgiRecords[totalRecord] := rec;
        end else
        begin
            totalRecord := length(fRecords);
            if (requestId < totalRecord) then
            begin
                //reuse slot
                initSingleRecord(requestId);
            end else
            begin
                //increase slot to include requestId in index + 10 additional slot
                //to avoid to many setLength call
                setLength(fRecords, requestId - totalRecord + 10);
            end;
            fRecords[requestId].used := true;
            setLength(fRecords[requestId].fcgiRecords,1);
            fRecords[requestId].fcgiRecords[0] := rec;
        end;

        markCompleteness(rec);
    end;

    (*!------------------------------------------------
     * remove request
     *-----------------------------------------------
     * @param requestId, request id to be removed
     * @return true of request is removed
     *-----------------------------------------------*)
    function TFcgiRequestManager.remove(const requestId : word) : boolean;
    var i : integer;
    begin
        fRecords[requestId].used := false;
        fRecords[requestId].env := nil;
        for i := length(fRecords[requestId].fcgiRecords) - 1 downto 0 do
        begin
            fRecords[requestId].fcgiRecords[i] := nil;
        end;
        setLength(fRecords[requestId].fcgiRecords, 0);
        result := true;
    end;

end.

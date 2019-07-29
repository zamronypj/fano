{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FcgiFrameParserImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    InjectableObjectImpl,
    FcgiRecordIntf,
    FcgiRecordFactoryIntf,
    FcgiFrameParserIntf,
    StreamAdapterIntf,
    MemoryAllocatorIntf,
    MemoryDeallocatorIntf;

type

    (*!-----------------------------------------------
     * FastCGI Frame Parser
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiFrameParser = class (TInjectableObject, IFcgiFrameParser, IMemoryAllocator, IMemoryDeallocator)
    private
        fRecordFactories : TFcgiRecordFactoryArray;

        procedure raiseExceptionIfBufferNil(const buffer : pointer);
        procedure raiseExceptionIfInvalidBufferSize(const bufferSize : int64);
        procedure raiseExceptionIfInvalidBuffer(const buffer : pointer;  const bufferSize : int64);

        function isValidRecordType(const reqType : byte) : boolean;
        procedure raiseExceptionIfInvalidRecordType(const reqType : byte);

        function readBytes(
            const stream : IStreamAdapter;
            buf : pointer;
            amountToRead : integer;
            out streamEmpty : boolean
        ) : integer;
    public
        constructor create(const factories : TFcgiRecordFactoryArray);
        destructor destroy(); override;

        (*!------------------------------------------------
         * read stream and return found record in memory buffer
         *-----------------------------------------------
         * @param bufPtr, memory buffer to store FastCGI record
         * @param bufSize, memory buffer size
         * @return true if stream is exhausted
         *-----------------------------------------------*)
        function readRecord(
            const stream : IStreamAdapter;
            out bufPtr : pointer;
            out bufSize : ptrUint
        ) : boolean;

        (*!------------------------------------------------
        * test if buffer contain FastCGI frame package
        * i.e FastCGI header + payload
        *-----------------------------------------------
        * @param buffer, pointer to current buffer
        * @return true if buffer contain valid frame
        *-----------------------------------------------*)
        function hasFrame(const buffer : pointer; const bufferSize : ptrUint) : boolean;

        (*!------------------------------------------------
         * parse current buffer and create its corresponding
         * FastCGI record instance
         *-----------------------------------------------
         * @param buffer, pointer to current buffer
         * @param bufferSize, size of buffer
         * @return IFcgiRecord instance
         * @throws EInvalidFcgiBuffer exception when buffer is nil
         * @throws EInvalidFcgiHeaderLen exception when header size not valid
         *-----------------------------------------------*)
        function parseFrame(const buffer : pointer; const bufferSize : ptrUint) : IFcgiRecord;

        (*!------------------------------------------------
         * allocate memory
         *-----------------------------------------------
         * @param requestedSize, number of bytes to allocate
         * @return pointer of allocated memory
         *-----------------------------------------------*)
        function allocate(const requestedSize : PtrUint) : pointer;

        (*!------------------------------------------------
         * deallocate memory
         *-----------------------------------------------
         * @param ptr, pointer of memory to be allocated
         * @param requestedSize, number of bytes to deallocate
         *-----------------------------------------------*)
        procedure deallocate(const ptr : pointer; const requestedSize : PtrUint);
    end;

implementation

uses

    sockets,
    baseunix,
    fastcgi,
    EInvalidFcgiBufferImpl,
    EInvalidFcgiRecordTypeImpl,
    EInvalidFcgiHeaderLenImpl;

    constructor TFcgiFrameParser.create(const factories : TFcgiRecordFactoryArray);
    begin
        inherited create();
        fRecordFactories := factories;
    end;

    destructor TFcgiFrameParser.destroy();
    var i : integer;
    begin
        inherited destroy();
        for i:= length(fRecordFactories) -1 downto 0 do
        begin
            fRecordFactories[i] := nil;
        end;
        setLength(fRecordFactories, 0);
        fRecordFactories := nil;
    end;

    procedure TFcgiFrameParser.raiseExceptionIfBufferNil(const buffer : pointer);
    begin
        if (buffer = nil) then
        begin
            raise EInvalidFcgiBuffer.create('FastCGI buffer nil');
        end;
    end;

    procedure TFcgiFrameParser.raiseExceptionIfInvalidBufferSize(const bufferSize : int64);
    begin
        if (bufferSize < FCGI_HEADER_LEN) then
        begin
            raise EInvalidFcgiHeaderLen.create('Not enough data in the buffer to parse');
        end;
    end;

    procedure TFcgiFrameParser.raiseExceptionIfInvalidBuffer(const buffer : pointer;  const bufferSize : int64);
    begin
        raiseExceptionIfBufferNil(buffer);
        raiseExceptionIfInvalidBufferSize(bufferSize);
    end;

    (*!------------------------------------------------
     * allocate memory
     *-----------------------------------------------
     * @param requestedSize, number of bytes to allocate
     * @return pointer of allocated memory
     *-----------------------------------------------*)
    function TFcgiFrameParser.allocate(const requestedSize : PtrUint) : pointer;
    begin
        result := getMem(requestedSize);
    end;

    (*!------------------------------------------------
     * deallocate memory
     *-----------------------------------------------
     * @param ptr, pointer of memory to be allocated
     * @param requestedSize, number of bytes to deallocate
     *-----------------------------------------------*)
    procedure TFcgiFrameParser.deallocate(const ptr : pointer; const requestedSize : PtrUint);
    begin
        freeMem(ptr, requestedSize);
    end;

    (*!------------------------------------------------
     * read stream and return found record in memory buffer
     *-----------------------------------------------
     * @param bufPtr, memory buffer to store FastCGI record
     * @param bufSize, memory buffer size
     * @return true if stream is exhausted
     *-----------------------------------------------*)
    function TFcgiFrameParser.readRecord(
        const stream : IStreamAdapter;
        out bufPtr : pointer;
        out bufSize : ptrUint
    ) : boolean;
    var tmp : pointer;
        header : FCGI_HEADER;
        totBytes, headerSize : integer;
        streamEmpty : boolean;
    begin
        result:= false;
        bufPtr := nil;
        bufSize := 0;
        headerSize := sizeof(FCGI_HEADER);
        totBytes := readBytes(stream, @header, headerSize, streamEmpty);

        if (streamEmpty) then
        begin
            result := true;
            exit;
        end;

        if (totBytes <> headerSize) then
        begin
            raise EInvalidFcgiHeaderLen.createFmt('Invalid header length %d', [totBytes]);
        end;

        bufSize := FCGI_HEADER_LEN + BEtoN(header.contentLength) + header.paddingLength;
        bufPtr := allocate(bufSize);
        //copy header and advance position to skip header part
        tmp := bufPtr;
        PFCGI_HEADER(tmp)^ := header;
        inc(tmp, headerSize);

        //read content and padding
        totBytes := readBytes(stream, tmp, bufSize - headerSize, streamEmpty) + totBytes;
        result := streamEmpty;
    end;

    function TFcgiFrameParser.readBytes(
        const stream : IStreamAdapter;
        buf : pointer;
        amountToRead : integer;
        out streamEmpty : boolean
    ) : integer;
    var bytesRead : int64;
        err : longint;
    begin
        result := 0;
        if amountToRead <= 0 then
        begin
            exit;
        end;

        streamEmpty := false;
        err := 0;
        repeat
            bytesRead := stream.read(buf^, amountToRead);
            if (bytesRead > 0) then
            begin
                dec(amountToRead, bytesRead);
                inc(buf, bytesRead);
                inc(result, bytesRead);
            end else
            if (bytesRead < 0) then
            begin
                err := socketError();
            end else
            begin
                streamEmpty := true;
            end;
        until (amountToRead = 0) or
            streamEmpty or
            //EAGAIN EWOULDBLOCK means socket is ready for IO but data is not
            //available yet. exit loop so we can retry later
            (err = ESysEAGAIN) or (err = ESysEWouldBlock);
    end;

    (*!------------------------------------------------
     * test if buffer contain FastCGI frame package
     * i.e FastCGI header + payload
     *-----------------------------------------------
     * @param buffer, pointer to current buffer
     * @param bufferSize, size of buffer
     * @return true if buffer contain valid frame
     *-----------------------------------------------*)
    function TFcgiFrameParser.hasFrame(const buffer : pointer; const bufferSize : ptrUint) : boolean;
    var header : PFCGI_Header;
        contentLength :word;
    begin
        raiseExceptionIfBufferNil(buffer);
        header := buffer;
        //header^.contentlength is big endian, convert it to native endian
        contentLength := BEtoN(header^.contentLength);
        result := (bufferSize >= (FCGI_HEADER_LEN + contentLength + header^.paddingLength));
    end;

    function TFcgiFrameParser.isValidRecordType(const reqType : byte) : boolean;
    begin
        result := (reqType = FCGI_BEGIN_REQUEST) or
                  (reqType = FCGI_ABORT_REQUEST) or
                  (reqType = FCGI_END_REQUEST) or
                  (reqType = FCGI_PARAMS) or
                  (reqType = FCGI_STDIN) or
                  (reqType = FCGI_STDOUT) or
                  (reqType = FCGI_STDERR) or
                  (reqType = FCGI_DATA) or
                  (reqType = FCGI_GET_VALUES) or
                  (reqType = FCGI_GET_VALUES_RESULT) or
                  (reqType = FCGI_UNKNOWN_TYPE);
    end;

    procedure TFcgiFrameParser.raiseExceptionIfInvalidRecordType(const reqType : byte);
    begin
        if (not isValidRecordType(reqType)) then
        begin
            raise EInvalidFcgiRecordType.createFmt('Invalid FCGI record type %d received', [reqType]);
        end;
    end;

    (*!------------------------------------------------
     * parse current buffer and create its corresponding
     * FastCGI record instance
     *-----------------------------------------------
     * @param buffer, pointer to current buffer
     * @param bufferSize, size of buffer
     * @return IFcgiRecord instance
     * @throws EInvalidFcgiHeaderLen exception when header size not valid
     *-----------------------------------------------*)
    function TFcgiFrameParser.parseFrame(const buffer : pointer; const bufferSize : ptrUint) : IFcgiRecord;
    var header : PFCGI_Header;
        factory : IFcgiRecordFactory;
    begin
        raiseExceptionIfInvalidBuffer(buffer, bufferSize);
        header := buffer;
        raiseExceptionIfInvalidRecordType(header^.reqtype);
        factory := fRecordFactories[header^.reqtype];
        factory.setDeallocator(self);
        try
            result := factory.setBuffer(buffer, bufferSize).build();
        finally
            //remove reference to ourself, so reference count properly incr/decr
            //to avoid memory leak
            factory.setDeallocator(nil);
            factory := nil;
        end;
    end;

end.

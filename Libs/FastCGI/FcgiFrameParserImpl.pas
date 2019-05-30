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
    FcgiFrameParserIntf,
    StreamAdapterIntf;

type

    (*!-----------------------------------------------
     * FastCGI Frame Parser
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiFrameParser = class (TInjectableObject, IFcgiFrameParser)
    private
        procedure raiseExceptionIfBufferNil(const buffer : pointer);
        procedure raiseExceptionIfInvalidBufferSize(const bufferSize : int64);
        procedure raiseExceptionIfInvalidBuffer(const buffer : pointer;  const bufferSize : int64);

        function isValidRecordType(const reqType : byte) : boolean;
        procedure raiseExceptionIfInvalidRecordType(const reqType : byte);
    public

        (*!------------------------------------------------
        * test if buffer contain FastCGI frame package
        * i.e FastCGI header + payload
        *-----------------------------------------------
        * @param buffer, pointer to current buffer
        * @return true if buffer contain valid frame
        *-----------------------------------------------*)
        function hasFrame(const buffer : pointer;  const bufferSize : int64) : boolean;

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
        function parseFrame(const buffer : pointer;  const bufferSize : int64) : IFcgiRecord;
    end;

implementation

uses

    fastcgi,
    EInvalidFcgiBufferImpl,
    EInvalidFcgiRecordTypeImpl,
    EInvalidFcgiHeaderLenImpl,
    FcgiBeginRequestFactory,
    FcgiAbortRequestFactory,
    FcgiParamsFactory;

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
     * test if buffer contain FastCGI frame package
     * i.e FastCGI header + payload
     *-----------------------------------------------
     * @param buffer, pointer to current buffer
     * @param bufferSize, size of buffer
     * @return true if buffer contain valid frame
     *-----------------------------------------------*)
    function TFcgiFrameParser.hasFrame(const buffer : pointer; const bufferSize : int64) : boolean;
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
                  (reqType = FCGI_UNKNOWN_TYPE) or
                  (reqType = FCGI_MAXTYPE);
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
    function TFcgiFrameParser.parseFrame(const buffer : pointer; const bufferSize : int64) : IFcgiRecord;
    var header : PFCGI_Header;
    begin
        raiseExceptionIfInvalidBuffer(buffer, bufferSize);
        header := buffer;
        raiseExceptionIfInvalidRecordType(header^.reqtype);
        result := nil;
        case header^.reqtype of
            FCGI_BEGIN_REQUEST :
                begin
                    result := (TFcgiBeginRequestFactory.create(buffer, bufferSize)).build();
                end;
            FCGI_ABORT_REQUEST :
                begin
                    result := (TFcgiAbortRequestFactory.create(buffer, bufferSize)).build();
                end;
            FCGI_END_REQUEST :
                begin
                    result := (TFcgiEndRequestFactory.create(buffer, bufferSize)).build();
                end;
            FCGI_PARAMS :
                begin
                    result := (TFcgiParamsFactory.create(buffer, bufferSize)).build();
                end;
            FCGI_STDIN :
                begin
                    result := (TFcgiStdInFactory.create(buffer, bufferSize)).build();
                end;
            FCGI_STDOUT :
                begin
                    result := (TFcgiStdOutFactory.create(buffer, bufferSize)).build();
                end;
            FCGI_STDERR :
                begin
                    result := (TFcgiStdErrFactory.create(buffer, bufferSize)).build();
                end;
            FCGI_DATA :
                begin
                    result := (TFcgiDataFactory.create(buffer, bufferSize)).build();
                end;
            FCGI_GET_VALUES :
                begin
                    result := (TFcgiGetValuesFactory.create(buffer, bufferSize)).build();
                end;
            FCGI_GET_VALUES_RESULT :
                begin
                    result := (TFcgiGetValuesResultFactory.create(buffer, bufferSize)).build();
                end;
            FCGI_UNKNOWN_TYPE :
                begin
                    result := (TFcgiUnknownFactory.create(buffer, bufferSize)).build();
                end;
        end;
    end;

end.

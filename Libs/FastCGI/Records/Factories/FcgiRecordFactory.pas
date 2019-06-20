{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FcgiRecordFactory;

interface

{$MODE OBJFPC}
{$H+}

uses

    FcgiRecordIntf,
    FcgiRecordFactoryIntf,
    StreamAdapterIntf;

type

    (*!-----------------------------------------------
     * Base fastcgi record factory
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiRecordFactory = class(TInterfacedObject, IFcgiRecordFactory)
    protected
        tmpBuffer : pointer;
        tmpSize : ptrUint;
        fRequestId : word;

        function initEmptyStream() : IStreamAdapter;
        function initStreamFromBuffer(const buffer : pointer; const size : ptrUint) : IStreamAdapter;
    public
        constructor create(const buffer : pointer; const size : ptrUint);

        function setBuffer(const buffer : pointer; const size : ptrUint) : IFcgiRecordFactory;

        (*!------------------------------------------------
         * build fastcgi record from stream
         *-----------------------------------------------
         * @param stream, stream instance where to write
         * @return number of bytes actually written
         *-----------------------------------------------*)
        function build() : IFcgiRecord; virtual; abstract;

        (*!------------------------------------------------
         * set request id
         *-----------------------------------------------
         * @return request id
         *-----------------------------------------------*)
        function setRequestId(const reqId : word) : IFcgiRecordFactory;
    end;

implementation

uses

    classes,
    StreamAdapterImpl;

    constructor TFcgiRecordFactory.create();
    begin
        setBuffer(nil, 0);
    end;

    function TFcgiRecordFactory.setBuffer(const buffer : pointer; const size : ptrUint) : IFcgiRecordFactory;
    begin
        tmpBuffer := buffer;
        tmpSize := size;
        result := self;
    end;

    function TFcgiRecordFactory.initEmptyStream() : IStreamAdapter;
    begin
        result := TStreamAdapter.create(TMemoryStream.create());
    end;

    function TFcgiRecordFactory.initStreamFromBuffer(const buffer : pointer; const size : int64) : IStreamAdapter;
    var stream :IStreamAdapter;
    begin
        stream := initEmptyStream();
        stream.writeBuffer(buffer^, size);
        stream.seek(0);
        result := stream;
    end;

    (*!------------------------------------------------
     * set request id
     *-----------------------------------------------
     * @return request id
     *-----------------------------------------------*)
    function TFcgiRecordFactory.setRequestId(const reqId : word) : IFcgiRecordFactory;
    begin
        fRequestId := reqId;
        result := self;
    end;
end.

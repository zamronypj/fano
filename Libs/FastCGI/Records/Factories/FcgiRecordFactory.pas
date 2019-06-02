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
    FcgiRecordFactoryIntf;

type

    (*!-----------------------------------------------
     * Base fastcgi record factory
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiRecordFactory = class(TInterfacedObject, IFcgiRecordFactory)
    protected
        tmpBuffer : pointer;
        tmpSize : int64;
        fRequestId : word;
    public
        constructor create(const buffer : pointer; const size : int64);

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

    constructor TFcgiRecordFactory.create(const buffer : pointer; const size : int64);
    begin
        tmpBuffer := buffer;
        tmpSize := size;
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

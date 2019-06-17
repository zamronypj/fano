{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FcgiUnknownType;

interface

{$MODE OBJFPC}
{$H+}

uses

    StreamAdapterIntf,
    FcgiRecord;

type

    (*!-----------------------------------------------
     * Unknown type record (FCGI_UNKNOWN_TYPE)
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiUnknownType = class(TFcgiRecord)
    public
        constructor create(
            const aVersion : byte;
            const aType : byte;
            const aRequestId : word;
            const dataStream : IStreamAdapter;
            const unknownType : byte
        );

        constructor create(
            const dataStream : IStreamAdapter;
            const requestId : word;
            const unknownType : byte
        );
    end;

implementation

uses

    fastcgi;

    constructor TFcgiUnknownType.create(
        const aVersion : byte;
        const aType : byte;
        const aRequestId : word;
        const dataStream : IStreamAdapter;
        const unknownType : byte
    );
    var reqBody : FCGI_UnknownTypeBody;
    begin
        inherited create(aVersion, aType, aRequestId, dataStream);
        fillDword(reqBody, sizeof(FCGI_UnknownTypeBody), 0);
        reqBody._type := unknownType;
        fContentData.seek(0);
        fContentData.writeBuffer(reqBody, sizeof(FCGI_UnknownTypeBody));
    end;

    constructor TFcgiUnknownType.create(
        const dataStream : IStreamAdapter;
        const requestId : word;
        const unknownType : byte
    );
    begin
        create(FCGI_VERSION_1, FCGI_UNKNOWN_TYPE, requestId, dataStream, unknownType);
    end;
end.

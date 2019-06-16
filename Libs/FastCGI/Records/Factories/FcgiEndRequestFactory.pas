{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FcgiEndRequestFactory;

interface

{$MODE OBJFPC}
{$H+}

uses

    FcgiRecordIntf,
    FcgiRecordFactory;

type

    (*!-----------------------------------------------
     * End Request record factory (FCGI_END_REQUEST)
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiEndRequestFactory = class(TFcgiRecordFactory)
    public
        (*!------------------------------------------------
         * build fastcgi record from stream
         *-----------------------------------------------
         * @return instance IFcgiRecord of corresponding fastcgi record
         *-----------------------------------------------*)
        function build() : IFcgiRecord; override;
    end;

implementation

uses

    fastcgi,
    fastcgiex,
    classes,
    FcgiEndRequest,
    StreamAdapterImpl;


    (*!------------------------------------------------
     * build fastcgi record from stream
     *-----------------------------------------------
     * @return instance IFcgiRecord of corresponding fastcgi record
     *-----------------------------------------------*)
    function TFcgiEndRequestFactory.build() : IFcgiRecord;
    var rec : PFCGI_EndRequestRecord;
        appStatus : cardinal;
    begin
        rec := tmpBuffer;
        appStatus := ((rec^.body.appStatusB3 shl 24) and $ff) or
                    ((rec^.body.appStatusB2 shl 16) and $ff) or
                    ((rec^.body.appStatusB1 shl 8) and $ff) or
                    (rec^.body.appStatusB0 and $ff);
        result := TFcgiEndRequest.create(
            TStreamAdapter.create(TMemoryStream.create()),
            rec^.header.requestID,
            rec^.body.protocolStatus,
            appStatus
        );
    end;
end.

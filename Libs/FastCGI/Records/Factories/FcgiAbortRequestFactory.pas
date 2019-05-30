{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FcgiAbortRequestFactory;

interface

{$MODE OBJFPC}
{$H+}

uses

    FcgiRecordIntf;

type

    (*!-----------------------------------------------
     * Abort Request record factory (FCGI_ABORT_REQUEST)
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiAbortRequestFactory = class(TFcgiRecordFactory)
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
    FcgiAbortRequest;


    (*!------------------------------------------------
     * build fastcgi record from stream
     *-----------------------------------------------
     * @return instance IFcgiRecord of corresponding fastcgi record
     *-----------------------------------------------*)
    function TFcgiAbortRequestFactory.build() : IFcgiRecord;
    var rec : PFCGI_Header;
    begin
        rec := tmpBuffer;
        result := TFcgiAbortRequest.create(rec^.requestID);
    end;
end.

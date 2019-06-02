{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FcgiStreamRecordFactory;

interface

{$MODE OBJFPC}
{$H+}

uses

    FcgiRecordIntf,
    FcgiRecordFactory;

type

    (*!-----------------------------------------------
     * Stream record factory base class
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiStreamRecordFactory = class(TFcgiRecordFactory)
    protected
        function createStreamRecordType(const reqId : word; const content : string) : IFcgiRecord; virtual; abstract;
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
    classes;


    (*!------------------------------------------------
     * build fastcgi record from stream
     *-----------------------------------------------
     * @return instance IFcgiRecord of corresponding fastcgi record
     *-----------------------------------------------*)
    function TFcgiStreamRecordFactory.build() : IFcgiRecord;
    var rec : PFCGI_ContentRecord;
        content : TStringStream;
    begin
        content := TStringStream.create('');
        try
            rec := tmpBuffer;
            content.writeBuffer(rec^.contentData, rec^.header.contentLength);
            result := createStreamRecordType(rec^.header.requestID, content.dataString);
        finally
            content.free();
        end;
    end;
end.

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
    FcgiRecordFactory,
    FcgiStreamRecord;

type

    (*!-----------------------------------------------
     * Stream record factory base class
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiStreamRecordFactory = class(TFcgiRecordFactory)
    protected
        function getStreamRecordType() : TFcgiStreamRecordClass; virtual; abstract;
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

    fastcgi;


    (*!------------------------------------------------
     * build fastcgi record from stream
     *-----------------------------------------------
     * @return instance IFcgiRecord of corresponding fastcgi record
     *-----------------------------------------------*)
    function TFcgiStreamRecordFactory.build() : IFcgiRecord;
    var rec : PFCGI_ContentRecord;
        content : TStringStream;
        streamRecordType : TFcgiStreamRecordClass;
    begin
        content := TStringStream.create('');
        try
            rec := tmpBuffer;
            content.writeBuffer(rec^.contentData, rec^.contentLength);
            streamRecordType := getStreamRecordType();
            result := streamRecordType.create(rec^.requestID, content.dataString);
        finally
            content.free();
        end;
    end;
end.

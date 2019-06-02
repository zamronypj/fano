{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FcgiDataFactory;

interface

{$MODE OBJFPC}
{$H+}

uses

    FcgiRecordIntf,
    FcgiStreamRecordFactory;

type

    (*!-----------------------------------------------
     * Data record factory (FCGI_DATA)
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiDataFactory = class(TFcgiStreamRecordFactory)
    protected
        (*!------------------------------------------------
         * get stream record type
         *-----------------------------------------------
         * @return IFcgiRecord instance
         *-----------------------------------------------*)
        function createStreamRecordType(const reqId : word; const content : string) : IFcgiRecord; override;
    end;

implementation

uses

    fastcgi,
    FcgiData;


    (*!------------------------------------------------
     * get stream record type
     *-----------------------------------------------
     * @return IFcgiRecord instance
     *-----------------------------------------------*)
    function TFcgiDataFactory.createStreamRecordType(const reqId : word; const content : string) : IFcgiRecord;
    begin
        result := TFcgiData.create(reqId, content);
    end;
end.

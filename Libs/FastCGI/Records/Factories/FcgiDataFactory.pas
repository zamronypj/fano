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

    FcgiStreamRecord,
    FcgiStreamRecordFactory;

type

    (*!-----------------------------------------------
     * Data record factory (FCGI_DATA)
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiDataFactory = class(TFcgiStreamRecordFactory)
    protected
        function getStreamRecordType() : TFcgiStreamRecordClass; override;
    end;

implementation

uses

    fastcgi,
    FcgiData;


    (*!------------------------------------------------
     * get stream record type
     *-----------------------------------------------
     * @return TFcgiStreamRecord type descendant
     *-----------------------------------------------*)
    function TFcgiDataFactory.getStreamRecordType() : TFcgiStreamRecordClass;
    begin
        result := TFcgiData;
    end;
end.

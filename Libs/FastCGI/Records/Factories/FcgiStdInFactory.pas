{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FcgiStdInFactory;

interface

{$MODE OBJFPC}
{$H+}

uses

    FcgiStreamRecord,
    FcgiStreamRecordFactory;

type

    (*!-----------------------------------------------
     * StdIn record factory (FCGI_STDIN)
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiStdInFactory = class(TFcgiStreamRecordFactory)
    protected
        function getStreamRecordType() : TFcgiStreamRecordClass; override;
    end;

implementation

uses

    fastcgi,
    FcgiStdIn;


    (*!------------------------------------------------
     * get stream record type
     *-----------------------------------------------
     * @return TFcgiStreamRecord type descendant
     *-----------------------------------------------*)
    function TFcgiStdInFactory.getStreamRecordType() : TFcgiStreamRecordClass;
    begin
        result := TFcgiStdIn;
    end;
end.

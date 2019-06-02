{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FcgiStdErrFactory;

interface

{$MODE OBJFPC}
{$H+}

uses

    FcgiStreamRecord,
    FcgiStreamRecordFactory;

type

    (*!-----------------------------------------------
     * StdErr record factory (FCGI_STDERR)
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiStdErrFactory = class(TFcgiStreamRecordFactory)
    protected
        function getStreamRecordType() : TFcgiStreamRecordClass; override;
    end;

implementation

uses

    fastcgi,
    FcgiStdErr;

    (*!------------------------------------------------
     * get stream record type
     *-----------------------------------------------
     * @return TFcgiStreamRecord type descendant
     *-----------------------------------------------*)
    function TFcgiStdErrFactory.getStreamRecordType() : TFcgiStreamRecordClass;
    begin
        result := TFcgiStdErr;
    end;
end.

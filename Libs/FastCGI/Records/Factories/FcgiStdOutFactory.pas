{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FcgiStdOutFactory;

interface

{$MODE OBJFPC}
{$H+}

uses

    FcgiStreamRecord,
    FcgiStreamRecordFactory;

type

    (*!-----------------------------------------------
     * StdOut record factory (FCGI_STDOUT)
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiStdOutFactory = class(TFcgiStreamRecordFactory)
    protected
        function getStreamRecordType() : TFcgiStreamRecordClass; override;
    end;

implementation

uses

    fastcgi,
    FcgiStdOut;


    (*!------------------------------------------------
     * get stream record type
     *-----------------------------------------------
     * @return TFcgiStreamRecord type descendant
     *-----------------------------------------------*)
    function TFcgiStdOutFactory.getStreamRecordType() : TFcgiStreamRecordClass;
    begin
        result := TFcgiStdOut;
    end;
end.

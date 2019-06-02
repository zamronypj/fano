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

    FcgiRecordIntf,
    FcgiStreamRecordFactory;

type

    (*!-----------------------------------------------
     * StdErr record factory (FCGI_STDERR)
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiStdErrFactory = class(TFcgiStreamRecordFactory)
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
    FcgiStdErr;

    (*!------------------------------------------------
     * get stream record type
     *-----------------------------------------------
     * @return IFcgiRecord instance
     *-----------------------------------------------*)
    function TFcgiStdErrFactory.createStreamRecordType(const reqId : word; const content : string) : IFcgiRecord;
    begin
        result := TFcgiStdErr.create(reqId, content);
    end;
end.

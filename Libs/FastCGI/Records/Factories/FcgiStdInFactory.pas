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

    FcgiRecordIntf,
    FcgiStreamRecordFactory;

type

    (*!-----------------------------------------------
     * StdIn record factory (FCGI_STDIN)
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiStdInFactory = class(TFcgiStreamRecordFactory)
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
    FcgiStdIn;


    (*!------------------------------------------------
     * get stream record type
     *-----------------------------------------------
     * @return IFcgiRecord instance
     *-----------------------------------------------*)
    function TFcgiStdInFactory.createStreamRecordType(const reqId : word; const content : string) : IFcgiRecord; override;
    begin
        result := TFcgiStdIn.create(reqId, content);
    end;
end.

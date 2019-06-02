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

    FcgiRecordIntf,
    FcgiStreamRecordFactory;

type

    (*!-----------------------------------------------
     * StdOut record factory (FCGI_STDOUT)
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiStdOutFactory = class(TFcgiStreamRecordFactory)
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
    FcgiStdOut;


    (*!------------------------------------------------
     * get stream record type
     *-----------------------------------------------
     * @return IFcgiRecord instance
     *-----------------------------------------------*)
    function TFcgiStdOutFactory.createStreamRecordType(const reqId : word; const content : string) : IFcgiRecord; override;
    begin
        result := TFcgiStdOut.create(reqId, content);
    end;
end.

{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit FcgiRecordManagerImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    Classes,
    EnvironmentIntf,
    StreamAdapterIntf,
    FcgiProcessorIntf,
    FcgiFrameParserIntf;

type

    (*!-----------------------------------------------
     * Helper class that manage FastCGI record based on
     * request id and record type
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiRecordManager = class(TInterfacedObject, IFcgiRecordManager)
    private
    public
        function addBeginRequest(const reqId : word; const rec : IFcgiRecord) : IFcgiRecordManager;
        function getBeginRequest(const reqId : word) : IFcgiRecord;

        function addParams(const reqId : word; const rec : IFcgiRecord) : IFcgiRecordManager;
        function getParams(const reqId : word) : IFcgiRecord;
    end;

implementation


end.

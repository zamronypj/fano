{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit GuidSessionIdGeneratorImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    SessionIdGeneratorIntf;

type

    (*!------------------------------------------------
     * basic class having capability to
     * generate session id using GUID
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TGuidSessionIdGenerator = class(TInterfacedObject, ISessionIdGeneratorIntf)
    public
        (*!------------------------------------
         * get session id
         *-------------------------------------
         * @return session id string
         *-------------------------------------*)
        function getSessionId() : string;
    end;

implementation

uses

    SysUtils;

    (*!------------------------------------
     * get session id
     *-------------------------------------
     * @return session id string
     *-------------------------------------*)
    function TGuidSessionIdGenerator.getSessionId() : string;
    var id : TGUID;
    begin
        createGUID(id);
        //convert GUID to string and remove { and } part
        result := copy(GUIDToString(id), 2, 36);
    end;

end.

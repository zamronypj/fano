{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit CsrfImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    RequestIntf,
    CsrfIntf,
    SessionIntf;

type

    (*!------------------------------------------------
     * basic class having capability to
     * generate token to protect Cross-Site Request Forgery
     * (CSRF) attack
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TCsrf = class(TInterfacedObject, ICsrf)
    public

        (*!------------------------------------------------
         * generate token name and value
         *-------------------------------------------------
         * @param tokenName token name
         * @param tokenValue token value
         * @return current instance
         *-------------------------------------------------*)
        function generateToken(out tokenName : string; out tokenValue : string) : ICsrf;

        (*!------------------------------------------------
         * test if request has valid token
         *-------------------------------------------------
         * @param request current request
         * @param sess current session
         * @param nameKey key contains name of token
         * @param valueKey key contains value of token
         * @return current instance
         *-------------------------------------------------*)
        function hasValidToken(
            const request : IRequest;
            const sess : ISession;
            const nameKey : shortstring;
            const valueKey : shortstring
        ) : boolean;
    end;

implementation

uses

    SysUtils,
    sha1;

    (*!------------------------------------------------
     * generate token name and value
     *-------------------------------------------------
     * @param tokenName token name
     * @param tokenValue token value
     * @return current instance
     *-------------------------------------------------*)
    function TCsrf.generateToken(out tokenName : string; out tokenValue : string) : ICsrf;
    var id : TGUID;
        strId : string;
    begin
        createGUID(id);
        //convert GUID to string and remove { and } part
        strId := copy(GUIDToString(id), 2, 36);
        tokenValue := SHA1Print(SHA1String(strId));

        createGUID(id);
        //convert GUID to string and remove { and } part
        tokenName := copy(GUIDToString(id), 2, 36);
    end;

    (*!------------------------------------------------
     * test if request has valid token
     *-------------------------------------------------
     * @param request current request
     * @param session current session
     * @param nameKey key contains name of token
     * @param valueKey key contains value of token
     * @return current instance
     *-------------------------------------------------*)
    function TCsrf.hasValidToken(
        const request : IRequest;
        const sess : ISession;
        const nameKey : shortstring;
        const valueKey : shortstring
    ) : boolean;
    var tokenName, tokenValue : string;
        currTokenName, currTokenValue : string;
    begin
        tokenName := request.getParsedBodyParam(nameKey);
        tokenValue := request.getParsedBodyParam(valueKey);
        currTokenName := sess.getVar(nameKey);
        currTokenValue := sess.getVar(valueKey);
        result := (tokenName = currTokenName) and (tokenValue = currTokenValue);
    end;

end.

{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit UrandomCsrfImpl;

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
    TUrandomCsrf = class(TInterfacedObject, ICsrf)
    private
        fRandom: IRandom;
        fStrength : integer;
    public
        constructor create(const randomInst : IRandom);
        destructor destroy(); override;

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
    Base64,
    sha1;

    constructor TUrandomCsrf.create(
        const randomInst : IRandom;
        const strength : integer = 32
    );
    begin
        fRandom := randomInst;
        fStrength := strength;
    end;

    destructor TUrandomCsrf.destroy();
    begin
        fRandom := nil;
        inherited destroy();
    end;

    (*!------------------------------------------------
     * generate token name and value
     *-------------------------------------------------
     * @param tokenName token name
     * @param tokenValue token value
     * @return current instance
     *-------------------------------------------------*)
    function TUrandomCsrf.generateToken(out tokenName : string; out tokenValue : string) : ICsrf;
    var id : TGUID;
        strId : string;
    begin
        strId := TEncoding.UTF8.getBytes(fRandom.randomBytes(fStrength));
        tokenValue := SHA1Print(SHA1String(strId));

        createGUID(id);
        //convert GUID to string and remove { and } part
        tokenName := copy(GUIDToString(id), 2, 36);
        result := self;
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
    function TUrandomCsrf.hasValidToken(
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

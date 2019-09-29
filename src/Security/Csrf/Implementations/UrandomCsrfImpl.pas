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
    RandomIntf,
    SessionIntf,
    CsrfImpl;

type

    (*!------------------------------------------------
     * basic class having capability to
     * generate token to protect Cross-Site Request Forgery
     * (CSRF) attack using random generator
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TUrandomCsrf = class(TCsrf)
    private
        fRandom: IRandom;
        fStrength : integer;
    public

        (*!------------------------------------------------
         * constructor
         *-------------------------------------------------
         * @param randomInst random value generator
         * @param strength number of random bytes to generate
         *-------------------------------------------------*)
        constructor create(
            const secretKey : string;
            const randomInst : IRandom;
            const strength : integer = 32
        );

        destructor destroy(); override;

        (*!------------------------------------------------
         * generate token name and value
         *-------------------------------------------------
         * @param tokenName token name
         * @param tokenValue token value
         * @return current instance
         *-------------------------------------------------*)
        function generateToken(out tokenName : string; out tokenValue : string) : ICsrf; override;

    end;

implementation

uses

    SysUtils,
    Base64,
    hmac;

    (*!------------------------------------------------
     * constructor
     *-------------------------------------------------
     * @param randomInst random value generator
     * @param strength number of random bytes to generate
     *-------------------------------------------------*)
    constructor TUrandomCsrf.create(
        const secretKey : string;
        const randomInst : IRandom;
        const strength : integer = 32
    );
    begin
        inherited create(secretKey);
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
        strId : UTF8String;
    begin
        strId := TEncoding.UTF8.getString(fRandom.randomBytes(fStrength));
        tokenValue := HMACSHA1(fSecretKey, strId);

        createGUID(id);
        //convert GUID to string and remove { and } part
        tokenName := copy(GUIDToString(id), 2, 36);
        result := self;
    end;

end.

{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2020 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit AbstractHmacJwtAlgImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    JwtAlgIntf,
    JwtAlgSignIntf;

type

    (*!------------------------------------------------
     * class having capability to verify JWT token validity
     * with HMAC
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TAbstractHmacJwtAlg = class abstract (TInterfacedObject, IJwtAlg, IJwtAlgSign)
    protected
        function hmac(const inpStr : string; const secretKey: string) : string; virtual; abstract;
    public
        (*!------------------------------------------------
         * verify token
         *-------------------------------------------------
         * @param payload payload to verify
         * @param secretKey secret key
         * @return boolean true if token is verified
         *-------------------------------------------------*)
        function verify(const payload : string; const secretKey: string) : boolean;

        (*!------------------------------------------------
         * sign token
         *-------------------------------------------------
         * @param payload payload to verify
         * @param secretKey secret key
         * @return string signature
         *-------------------------------------------------*)
        function sign(const payload : string; const secretKey: string) : string;
    end;

implementation

    (*!------------------------------------------------
     * verify token
     *-------------------------------------------------
     * @param token token to verify
     * @return boolean true if token is verified
     *-------------------------------------------------*)
    function TAbstractHmacJwtAlg.verify(
        const payload: string;
        const signature : string;
        const secretKey: string
    ) : boolean;
    begin
        result := hmac(payload, secretKey) = signature;
    end;

    (*!------------------------------------------------
     * sign token
     *-------------------------------------------------
     * @param payload payload to verify
     * @param secretKey secret key
     * @return string signature
     *-------------------------------------------------*)
    function TAbstractHmacJwtAlg.sign(const payload : string; const secretKey: string) : string;
    begin
        result := hmac(payload, secretKey);
    end;
end.

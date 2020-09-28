{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2020 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit NoneHmacJwtAlgImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    JwtAlgIntf,
    JwtAlgSignIntf;

type

    (*!------------------------------------------------
     * null class having capability to verify JWT token validity
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TNullJwtAlg = class (TInterfacedObject, IJwtAlg, IJwtAlgSign)
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
    function TNoneJwtAlg.verify(
        const payload: string;
        const signature : string;
        const secretKey: string
    ) : boolean;
    begin
        result := true;
    end;

    (*!------------------------------------------------
     * sign token
     *-------------------------------------------------
     * @param payload payload to verify
     * @param secretKey secret key
     * @return string signature
     *-------------------------------------------------*)
    function TNoneJwtAlg.sign(const payload : string; const secretKey: string) : string;
    begin
        result := '';
    end;
end.

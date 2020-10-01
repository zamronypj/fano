{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2020 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit JwtConsts;

interface

{$MODE OBJFPC}
{$H+}

const

    (*!------------------------------------------------
     * JWT data
     *-------------------------------------------------*)
    JWT_ISSUER = 'iss';
    JWT_AUDIENCE = 'aud';

    (*!------------------------------------------------
     * Supported JWT signing algorithm
     *-------------------------------------------------
     * NONE = No signing
     * HS256 = HMAC SHA2-256
     * HS384 = HMAC SHA2-384
     * HS512 = HMAC SHA2-512
     *-------------------------------------------------*)
    ALG_NONE = 'none';
    ALG_HS256 = 'HS256';
    ALG_HS384 = 'HS384';
    ALG_HS512 = 'HS512';


implementation

end.

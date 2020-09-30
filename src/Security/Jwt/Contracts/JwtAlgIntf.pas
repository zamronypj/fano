{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2020 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit JwtAlgIntf;

interface

{$MODE OBJFPC}
{$H+}

type

    (*!------------------------------------------------
     * interface for any JWT algorithm class having
     * capability to verify jwt payload against its signature
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    IJwtAlg = interface
        ['{520D6E2D-70C1-43A5-8936-B79D48EA95C5}']

        (*!------------------------------------------------
         * verify token
         *-------------------------------------------------
         * @param payload payload to verify
         * @param signature signature to compare
         * @param secretKey secret key
         * @return boolean true if payload is verified
         *-------------------------------------------------
         * Note: payload is concatenated value of
         * base64url_header + '.' + base64url_claim
         *-------------------------------------------------*)
        function verify(
            const payload : string;
            const signature : string;
            const secretKey : string
        ) : boolean;

    end;

implementation

end.

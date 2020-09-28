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
     * interface for any class having capability to
     * verify jwt token
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    IJwtAlg = interface
        ['{520D6E2D-70C1-43A5-8936-B79D48EA95C5}']

        (*!------------------------------------------------
         * verify token
         *-------------------------------------------------
         * @param token token to verify
         * @return boolean true if token is verified
         *-------------------------------------------------*)
        function verify(const token : string; const secretKey : string) : boolean;

    end;

implementation

end.

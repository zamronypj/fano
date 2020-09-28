{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2020 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit JwtAlgSignIntf;

interface

{$MODE OBJFPC}
{$H+}

type

    (*!------------------------------------------------
     * interface for any class having capability to
     * generater jwt token signature
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    IJwtAlgSign = interface
        ['{7BF0C343-C778-44D8-A3DE-1C55956BA19E}']

        (*!------------------------------------------------
         * sign token
         *-------------------------------------------------
         * @param payload payload to sign
         * @param secretKey secret key
         * @return string signature
         *-------------------------------------------------*)
        function sign(const payload : string; const secretKey : string) : string;

    end;

implementation

end.

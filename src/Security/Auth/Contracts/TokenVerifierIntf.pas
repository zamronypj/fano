{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2020 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit TokenVerifierIntf;

interface

{$MODE OBJFPC}
{$H+}

type

    (*!------------------------------------------------
     * interface for any class having capability to
     * verify token validity
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    ITokenVerifier = interface
        ['{CADB73EB-A604-4177-8C95-21B03367D371}']

        (*!------------------------------------------------
         * verify token
         *-------------------------------------------------
         * @param token token to verify
         * @return boolean true if token is verified
         *-------------------------------------------------*)
        function verify(const token : string) : boolean;

    end;

implementation

end.

{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit CsrfIntf;

interface

{$MODE OBJFPC}
{$H+}

type

    (*!------------------------------------------------
     * interface for any class having capability to
     * generate token to protect Cross-Site Request Forgery
     * (CSRF) attack
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    ICsrf = interface
        ['{7B3FA924-39FD-4EE3-B782-F76A5559160F}']

        (*!------------------------------------------------
         * generate token name and value
         *-------------------------------------------------
         * @param tokenName token name
         * @param tokenValue token value
         * @return current instance
         *-------------------------------------------------*)
        function generateToken(out tokenName : string; out tokenValue :string) : ICsrf;

        (*!------------------------------------------------
         * validate token name and value
         *-------------------------------------------------
         * @param key token name
         * @param key token value
         * @return true if token match with previously generated
         *-------------------------------------------------*)
        function isTokenValid(const tokenName : string; const tokenValue :string) : boolean;
    end;

implementation

end.
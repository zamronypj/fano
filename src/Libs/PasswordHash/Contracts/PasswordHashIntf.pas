{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit PasswordHashIntf;

interface

{$MODE OBJFPC}
{$H+}

type

    (*!------------------------------------------------
     * interface for any class having capability to
     * hash password
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IPasswordHash = interface
        ['{C9AFE9DF-A867-4B43-9318-A1C487D1ECD0}']

        (*!------------------------------------------------
         * set hash generator cost
         *-----------------------------------------------
         * @param algorithmCost cost of hash generator
         * @return current instance
         *-----------------------------------------------*)
        function cost(const algorithmCost : integer) : IPasswordHash;

        (*!------------------------------------------------
         * set hash length
         *-----------------------------------------------
         * @param hashLen length of hash
         * @return current instance
         *-----------------------------------------------*)
        function len(const hashLen : integer) : IPasswordHash;

        (*!------------------------------------------------
         * set password salt
         *-----------------------------------------------
         * @param saltValue salt
         * @return current instance
         *-----------------------------------------------*)
        function salt(const saltValue : string) : IPasswordHash;

        (*!------------------------------------------------
         * generate password hash
         *-----------------------------------------------
         * @param plainPassw input password
         * @return password hash
         *-----------------------------------------------*)
        function hash(const plainPassw : string) : string;

        (*!------------------------------------------------
         * verify plain password against password hash
         *-----------------------------------------------
         * @param plainPassw input password
         * @param hashedPassw password hash
         * @return true if password match password hash
         *-----------------------------------------------*)
        function verify(
            const plainPassw : string;
            const hashedPasswd : string
        ) : boolean;
    end;

implementation
end.

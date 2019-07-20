{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit NullEnvironmentImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    AbstractEnvironmentImpl;

type

    (*!------------------------------------------------
     * dummy CGI environment variable
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *--------------------------------------------------*)
    TNullCGIEnvironment = class(TAbstractCGIEnvironment)
    public
        (*!-----------------------------------------
         * Retrieve an environment variable
         *------------------------------------------
         * @param key name of variable
         * @return variable value
         *------------------------------------------*)
        function env(const key : string) : string; override;
    end;

implementation


    (*!-----------------------------------------
     * Retrieve an environment variable
     *------------------------------------------
     * @param key name of variable
     * @return variable value
     *------------------------------------------*)
    function TNullCGIEnvironment.env(const key : string) : string;
    begin
        result := '';
    end;

end.

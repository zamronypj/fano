{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit EnvironmentImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    AbstractEnvironmentImpl;

type

    (*!------------------------------------------------
     * basic having capability to retrieve
     * CGI environment variable
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *--------------------------------------------------*)
    TCGIEnvironment = class(TAbstractCGIEnvironment)
    public
        (*!-----------------------------------------
         * Retrieve an environment variable
         *------------------------------------------
         * @param key name of variable
         * @return variable value
         *------------------------------------------*)
        function env(const keyName : string) : string; override;
    end;

implementation

uses

    dos;


    (*!-----------------------------------------
     * Retrieve an environment variable
     *------------------------------------------
     * @param key name of variable
     * @return variable value
     *------------------------------------------*)
    function TCGIEnvironment.env(const keyName : string) : string;
    begin
        result := getenv(keyName);
    end;

end.

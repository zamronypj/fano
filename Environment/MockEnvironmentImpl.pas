{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit MemEnvironmentImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    EnvironmentIntf,
    EnvironmentWriterIntf,
    EnvironmentImpl,
    KeyValueTypes;

type

    (*!------------------------------------------------
     * basic class having capability to retrieve
     * CGI environment variable from injected variable
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *--------------------------------------------------*)
    TMockCGIEnvironment = class(TCGIEnvironment, IEnvironmentWriter)
    private
        envVars : TArrayOfKeyValue;

        (*!-----------------------------------------
         * Retrieve index of an environment variable
         *------------------------------------------
         * @param key name of variable
         * @return index
         *------------------------------------------*)
        function indexOf(const key : string) : integer;
    public
        (*!-----------------------------------------
         * constructor
         *------------------------------------------*)
        constructor create();

        (*!-----------------------------------------
         * destructor
         *------------------------------------------*)
        destructor destroy(); override;

        (*!-----------------------------------------
         * Retrieve an environment variable
         *------------------------------------------
         * @param key name of variable
         * @return variable value
         *------------------------------------------*)
        function env(const key : string) : string; override;

        (*!-----------------------------------------
         * Retrieve an environment variable
         *------------------------------------------
         * @param key name of variable
         * @return variable value
         *------------------------------------------*)
        function setEnv(const key : string; const val : string) : IEnvironmentWriter;
    end;

implementation

    constructor TMockCGIEnvironment.create();
    begin
        envVars := nil;
    end;

    destructor TMockCGIEnvironment.destroy();
    begin
        inherited destroy();
        envVars := nil;
    end;

    (*!-----------------------------------------
     * Retrieve index of an environment variable
     *------------------------------------------
     * @param key name of variable
     * @return index
     *------------------------------------------*)
    function TMockCGIEnvironment.indexOf(const key : string) : integer;
    var i, totalVar : integer;
    begin
        result := -1;
        totalVar := length(envVars);
        //environment variables mostly not many so we run naive loop to find
        //correct key and returns its data
        for i:= 0 to totalVar-1 do
        begin
            if (envVars[i].key = key) then
            begin
                result := i;
                break;
            end;
        end;
    end;

    (*!-----------------------------------------
     * Retrieve an environment variable
     *------------------------------------------
     * @param key name of variable
     * @return variable value
     *------------------------------------------*)
    function TMockCGIEnvironment.env(const key : string) : string;
    var indx : integer;
    begin
        result := '';
        indx:= indexOf(key);
        if (indx >= 0) then
        begin
            //if we get here, it means we found key, return its value
            result := envVars[indx].value;
        end;
    end;

    (*!-----------------------------------------
     * Retrieve an environment variable
     *------------------------------------------
     * @param key name of variable
     * @return variable value
     *------------------------------------------*)
    function TMockCGIEnvironment.setEnv(const key : string; const val : string) : IEnvironmentWriter;
    var indx, len : integer;
    begin
        indx:= indexOf(key);
        if (indx >= 0) then
        begin
            //we found key, just update its value
            envVars[indx].value := val;
        end else
        begin
            //no key found, just add it
            //environment mostly not many so just add it naivelys
            len := length(envVars);
            setLength(envVars, len + 1);
            envVars[len].key := key;
            envVars[len].value := val;
        end;
        result := self;
    end;
end.

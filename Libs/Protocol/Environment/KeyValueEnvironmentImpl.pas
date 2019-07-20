{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit KeyValueEnvironmentImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    DependencyIntf,
    EnvironmentIntf,
    KeyValuePairIntf,
    EnvironmentImpl;

type

    (*!------------------------------------------------
     * basic having capability to retrieve
     * CGI environment variable from key value pair
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *--------------------------------------------------*)
    TKeyValueEnvironment = class(TCGIEnvironment)
    private
        envVars : IKeyValuePair;
    public
        constructor create(const aEnvVars : IKeyValuePair);
        destructor destroy(); override;

        {-----------------------------------------
         Retrieve an environment variable
        ------------------------------------------}
        function env(const key : string) : string; override;
    end;

implementation

    constructor TKeyValueEnvironment.create(const aEnvVars : IKeyValuePair);
    begin
        envVars := aEnvVars;
    end;

    destructor TKeyValueEnvironment.destroy();
    begin
        inherited destroy();
        envVars := nil;
    end;

    {-----------------------------------------
     Retrieve an environment variable
    ------------------------------------------}
    function TKeyValueEnvironment.env(const key : string) : string;
    begin
        if (envVars.has(key)) then
        begin
            result := envVars.getValue(key);
        end else
        begin
            result := '';
        end;
    end;

end.

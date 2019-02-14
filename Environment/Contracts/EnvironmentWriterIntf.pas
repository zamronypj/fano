{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit EnvironmentWriterIntf;

interface

{$MODE OBJFPC}
{$H+}

type

    (*!------------------------------------------------
     * interface for any class having capability to retrieve
     * set environment variable
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    IEnvironmentWriter = interface
        ['{40E6FABD-B4F3-44C9-AF4B-85C146067996}']

        {-----------------------------------------
         set an environment variable
        ------------------------------------------}
        function setEnv(const key : string; const val : string) : IEnvironmentWriter;
    end;

implementation
end.

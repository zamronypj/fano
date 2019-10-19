{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit UwsgiParserIntf;

interface

{$MODE OBJFPC}
{$H+}

uses

    EnvironmentIntf,
    StreamAdapterIntf;

type

    (*!-----------------------------------------------
     * Interface for any class having capability to parse
     * uwsgi protocol binary data
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IUwsgiParser = interface
        ['{A678943F-AE7A-4A5F-BD74-505B859E9CE0}']

        (*!------------------------------------------------
         * parse stream
         *-----------------------------------------------*)
        function parse(const stream : IStreamAdapter) : boolean;

        (*!------------------------------------------------
         * get POST data
         *-----------------------------------------------
         * @return IStreamAdapter instance
         *-----------------------------------------------*)
        function getStdIn() : IStreamAdapter;

        (*!------------------------------------------------
         * get environment variable from request
         *-----------------------------------------------
         * @return ICGIEnvironment instance
         *-----------------------------------------------*)
        function getEnv() : ICGIEnvironment;
    end;

implementation

end.

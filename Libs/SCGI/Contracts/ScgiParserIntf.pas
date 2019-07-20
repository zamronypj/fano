{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ScgiParserIntf;

interface

{$MODE OBJFPC}
{$H+}

uses

    EnvironmentIntf,
    StreamAdapterIntf;

type

    (*!-----------------------------------------------
     * Interface for any class having capability to parse
     * SCGI string
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IScgiParser = interface
        ['{D0607EED-62DE-4D37-B9BB-A83ECD66032E}']

        (*!------------------------------------------------
         * parse stream
         *-----------------------------------------------*)
        procedure parse(const stream : IStreamAdapter);

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

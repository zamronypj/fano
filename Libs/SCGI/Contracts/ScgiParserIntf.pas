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
         * parse current string and extract environment variable
         * and POST data
         *-----------------------------------------------
         * @param buffer, pointer to current buffer
         * @param bufferSize, size of buffer
         * @return IFcgiRecord instance
         * @throws EInvalidFcgiBuffer exception when buffer is nil
         * @throws EInvalidFcgiHeaderLen exception when header size not valid
         *-----------------------------------------------*)
        function setNetString(const netString : string) : IScgiParser;

        (*!------------------------------------------------
         * extract environment variable from netstring
         *-----------------------------------------------
         * @return ICGIEnvironment instance
         *-----------------------------------------------*)
        function getStdIn() : IStreamAdapter;

        (*!------------------------------------------------
         * extract environment variable from netstring
         *-----------------------------------------------
         * @return ICGIEnvironment instance
         *-----------------------------------------------*)
        function getEnv() : ICGIEnvironment;
    end;

implementation

end.

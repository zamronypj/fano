{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FormUrlencodedParserIntf;

interface

{$MODE OBJFPC}
{$H+}

uses

    ListIntf;

type

    (*!----------------------------------------------
     * interface for any class having capability as
     * parse raw data into parsed data
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IFormUrlencodedParser = interface
        ['{CE9CEF0D-E354-453D-9A81-0181BC87BD28}']

        (*!----------------------------------------
         * Read raw data and parse
         * it and store parsed data in parsed data parameter
         *------------------------------------------
         * @param rawData raw data from web server
         * @param parsedData instance of IList that will store
         *             parsed body parameter
         * @return current instance
         *------------------------------------------*)
        function parse(
            const rawData : string;
            const parsedData : IList
        ) : IFormUrlencodedParser;
    end;

implementation
end.

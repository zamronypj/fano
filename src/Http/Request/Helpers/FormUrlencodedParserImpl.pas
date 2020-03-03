{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FormUrlencodedParserImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    Classes,
    ListIntf,
    DependencyContainerIntf,
    UrlencodedParserImpl,
    EnvironmentIntf;

type

    (*!----------------------------------------------
     * basic implementation having capability as
     * parse application/x-www-form-urlencoded request
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFormUrlencodedParser = class(TUrlencodedParser)
    public

        (*!----------------------------------------
         * Read POST data and parse
         * it and store parsed data in body request parameter
         *------------------------------------------
         * @param postData POST data from web server
         * @param body instance of IList that will store
         *             parsed body parameter
         * @return current instance
         *-------------------------------------------
         *------------------------------------------*)
        function parse(
            const rawData : string;
            const parsedData : IList
        ) : IFormUrlencodedParser;
    end;

implementation

uses

    sysutils,
    EInvalidRequestImpl;

    (*!----------------------------------------
     * Read POST data in standard input and parse
     * it and store parsed data in body request parameter
     *------------------------------------------
     * @param rawData raw request body string
     * @param parsedData instance of IList that will store
     *             parsed body parameter
     * @return current instance
     *------------------------------------------
     * @link : https://tools.ietf.org/html/rfc7578
     *------------------------------------------*)
    function TFormUrlencodedParser.parse(
        const rawData : string;
        const parsedData : IList
    ) : IFormUrlencodedParser;
    begin
        initParamsFromString(rawData, parsedData, '&');
        result := self;
    end;
end.

{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit CookiesParserImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    Classes,
    ListIntf,
    DependencyContainerIntf,
    UrlencodedParserImpl,
    FormUrlencodedParserIntf,
    CookiesParserIntf;

type

    (*!----------------------------------------------
     * basic implementation having capability as
     * parse cookies request
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TCookiesParser = class(TUrlencodedParser, ICookiesParser)
    public

        (*!----------------------------------------
         * Read raw cookies string data and parse
         * it and store parsed data in body request parameter
         *------------------------------------------
         * @param postData raw cookie data from web server
         * @param body instance of IList that will store
         *             parsed body parameter
         * @return current instance
         *------------------------------------------*)
        function parse(
            const rawData : string;
            const parsedData : IList
        ) : IFormUrlencodedParser;
    end;

implementation

    (*!----------------------------------------
     * Read POST data in standard input and parse
     * it and store parsed data in body request parameter
     *------------------------------------------
     * @param postData raw request body string
     * @param body instance of IList that will store
     *             parsed body parameter
     * @return current instance
     *------------------------------------------
     * @link : https://tools.ietf.org/html/rfc7578
     *------------------------------------------*)
    function TCookiesParser.parse(
        const rawData: string;
        const parsedData: IList
    ) : IFormUrlencodedParser;
    begin
        initParamsFromString(rawData, parsedData, ';');
        result := self;
    end;
end.

{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit TemplateViewImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    ViewImpl,
    TemplateParserIntf,
    FileReaderIntf;

type

    (*!------------------------------------------------
     * View that can render from a HTML template file
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TTemplateView = class(TView)
    public

        (*!------------------------------------------------
         * constructor
         *------------------------------------------------
         * @param tplPath template filepath
         * @param templateParserInst template variable parser
         * @param templateReaderInst template file reader
         *-----------------------------------------------*)
        constructor create(
            const tplPath : string;
            const templateParserInst : ITemplateParser;
            templateReaderInst : IFileReader
        );
    end;

implementation

    (*!------------------------------------------------
     * constructor
     *------------------------------------------------
     * @param tplPath template filepath
     * @param templateParserInst template variable parser
     * @param templateReaderInst template file reader
     *-----------------------------------------------*)
    constructor TTemplateView.create(
        const tplPath : string;
        const templateParserInst : ITemplateParser;
        templateReaderInst : IFileReader
    );
    begin
        inherited create(
            templateParserInst,
            templateReaderInst.readFile(tplPath)
        );
    end;

end.

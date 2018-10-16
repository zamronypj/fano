{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}

unit TemplateParserFactoryImpl;

interface
{$H+}

uses
    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl;

type
    {------------------------------------------------
     basic class that can create template parser
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TTemplateParserFactory = class(TFactory, IDependencyFactory)
    private
        openTag : string;
        closeTag : string;
    public
        constructor create(
            const openTagStr : string = '{{';
            const closeTagStr : string = '}}'
        );
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses
    TemplateParserImpl,
    RegexImpl;

    constructor TTemplateParserFactory.create(
        const openTagStr : string = '{{';
        const closeTagStr : string = '}}'
    );
    begin
        openTag := openTagStr;
        closeTag := closeTagStr;
    end;

    function TTemplateParserFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        //replace any variable {{ variableName }} with value
        result := TTemplateParser.create(
            TRegex.create(),
            openTag,
            closeTag
        );
    end;
end.

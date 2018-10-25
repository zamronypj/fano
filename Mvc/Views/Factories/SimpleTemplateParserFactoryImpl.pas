{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}

unit SimpleTemplateParserFactoryImpl;

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
    TSimpleTemplateParserFactory = class(TFactory, IDependencyFactory)
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
    SimpleTemplateParserImpl;

    constructor TSimpleTemplateParserFactory.create(
        const openTagStr : string = '{{';
        const closeTagStr : string = '}}'
    );
    begin
        openTag := openTagStr;
        closeTag := closeTagStr;
    end;

    function TSimpleTemplateParserFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        //replace any variable {{variableName}} with value
        result := TSimpleTemplateParser.create(
            openTag,
            closeTag
        );
    end;
end.

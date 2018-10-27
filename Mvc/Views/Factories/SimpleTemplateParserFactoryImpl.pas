{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit SimpleTemplateParserFactoryImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    DependencyIntf,
    DependencyContainerIntf,
    BaseTemplateParserFactoryImpl;

type

    (*!------------------------------------------------
     * basic class that can create simple template parser
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TSimpleTemplateParserFactory = class(TBaseTemplateParserFactory, IDependencyFactory)
    public
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses
    SimpleTemplateParserImpl;

    function TSimpleTemplateParserFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        //replace any variable {{variableName}} with value
        result := TSimpleTemplateParser.create(
            openTag,
            closeTag
        );
    end;
end.

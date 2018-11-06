{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit TemplateParserFactoryImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    DependencyIntf,
    DependencyContainerIntf,
    BaseTemplateParserFactoryImpl;

type

    (*!------------------------------------------------
     * basic class that can create template parser
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TTemplateParserFactory = class(TBaseTemplateParserFactory, IDependencyFactory)
    public
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses
    TemplateParserImpl,
    RegexImpl;

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

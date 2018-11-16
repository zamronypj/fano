{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ViewPartialFactoryImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    ViewParametersIntf,
    ViewPartialIntf,
    TemplateParserIntf;

type

    (*!------------------------------------------------
     * View that can render from a HTML template to string
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TViewPartialFactory = class(TFactory)
    private
        parser : ITemplateParser;
    public
        constructor create(const parserInst : ITemplateParser);
        destructor destroy(); override;

        (*!---------------------------------------------------
         * build class instance
         *----------------------------------------------------
         * @param container dependency container instance
         *---------------------------------------------------*)
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses

    ViewPartialImpl;

    constructor TViewPartialFactory.create(const parserInst : ITemplateParser);
    begin
        parser := parserInst;
    end;

    destructor TViewPartialFactory.destroy();
    begin
        inherited destroy();
        parser := nil;
    end;

    (*!---------------------------------------------------
     * build class instance
     *----------------------------------------------------
     * @param container dependency container instance
     *---------------------------------------------------*)
    function TViewPartialFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TViewPartial.create(parser);
    end;

end.

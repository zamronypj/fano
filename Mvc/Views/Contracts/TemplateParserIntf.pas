{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit TemplateParserIntf;

interface

{$MODE OBJFPC}
{$H+}

uses

    ViewParametersIntf;

type

    (*!------------------------------------------------
     * interface for any class having capability parse
     * template and replace variable placeholder with value
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    ITemplateParser = interface
        ['{06146BC7-5543-4FD1-956C-9FC47122EC70}']

        (*!---------------------------------------------------
         * replace template content with view parameters
         * ----------------------------------------------------
         * @param templateStr string contain content of template
         * @param viewParams view parameters instance
         * @return replaced content
         *-----------------------------------------------------*)
        function parse(
            const templateStr : string;
            const viewParams : IViewParameters
        ) : string;
    end;

implementation

end.

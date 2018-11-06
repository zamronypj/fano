{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit TemplateFetcherIntf;

interface

{$MODE OBJFPC}
{$H+}

uses

    ViewParametersIntf;

type

    (*!------------------------------------------------
     * interface for any class having capability to
     * read template file and replace its content with value
     * and output to string
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    ITemplateFetcher = interface
        ['{22C26574-8709-4106-9EE9-84EA86F4567C}']

        function fetch(
            const templatePath : string;
            const viewParams : IViewParameters
        ) : string;
    end;

implementation
end.

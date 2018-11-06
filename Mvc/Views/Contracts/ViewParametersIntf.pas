{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit ViewParametersIntf;

interface

{$MODE OBJFPC}
{$H+}

uses

    classes;

type

    (*!------------------------------------------------
     * interface for any class having capability as
     * view parameters
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IViewParameters = interface
        ['{F93CA7D6-4454-4A04-A585-78BFF12F49E3}']
        function vars() : TStrings;
        function getVar(const varName : shortstring) : string;
        function setVar(const varName : shortstring; const valueData :string) : IViewParameters;
    end;

implementation
end.

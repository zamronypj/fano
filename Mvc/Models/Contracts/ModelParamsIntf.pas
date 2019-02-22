{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ModelParamsIntf;

interface

{$MODE OBJFPC}
{$H+}

type

    (*!------------------------------------------------
     * interface that store model parameter data
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IModelParams = interface
        ['{6CB5843D-56E3-4012-AB5B-7A354A0EE5D3}']

        function writeString(const key : shortstring; const value : string) : IModelParams; overload;
        function writeInteger(const key : shortstring; const value : integer) : IModelParams; overload;

        function readString(const key : shortstring) : string; overload;
        function readInteger(const key : shortstring) : integer; overload;
    end;

implementation

end.

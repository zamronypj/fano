{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ModelParamImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    ModelParamsIntf;

type

    (*!------------------------------------------------
     * store model parameter data
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TModelParam = class (TInterfacedObject, IModelParams)
    public
        function writeString(const key : shortstring; const value : string) : IModelParams; overload;
        function writeInteger(const key : shortstring; const value : integer) : IModelParams; overload;

        function readString(const key : shortstring) : string; overload;
        function readInteger(const key : shortstring) : integer; overload;
    end;

implementation

    function TModelParam.writeString(const key : shortstring; const value : string) : IModelParams; overload;
    begin
    end;

    function TModelParam.writeInteger(const key : shortstring; const value : integer) : IModelParams; overload;
    begin

    end;

    function TModelParam.readString(const key : shortstring) : string; overload;
    begin

    end;

    function TModelParam.readInteger(const key : shortstring) : integer; overload;
    begin

    end;

end.

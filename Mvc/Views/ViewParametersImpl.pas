{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit ViewParametersImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    classes,
    contnrs,
    DependencyIntf,
    ViewParametersIntf;

type

    (*!------------------------------------------------
     * class having capability to store view parameters
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TViewParameters = class(TInterfacedObject, IViewParameters, IDependency)
    private
        keyValueMap : TFPHashList;
        keys : TStringList;
        procedure clearVars();
    public
        constructor create();
        destructor destroy(); override;
        function vars() : TStrings;
        function getVar(const varName : shortstring) : string;
        function setVar(const varName : shortstring; const valueData :string) : IViewParameters;
    end;

implementation

uses

    EKeyNotFoundImpl;

resourcestring

    sKeyNotFound = 'View parameter %s not found.';

type

    TValue = record
        data : string;
    end;
    PValue = ^TValue;


    constructor TViewParameters.create();
    begin
        keyValueMap := TFPHashList.create();
        keys := TStringList.create();
    end;

    procedure TViewParameters.clearVars();
    var i :integer;
        param : PValue;
    begin
        for i:=keyValueMap.count-1 downto 0 do
        begin
            param := keyValueMap.find(keyValueMap.nameOfIndex(i));
            setlength(param^.data, 0);
            dispose(param);
            keyValueMap.delete(i);
        end;
    end;

    destructor TViewParameters.destroy();
    begin
        inherited destroy();
        clearVars();
        keyValueMap.free();
        keys.free();
    end;

    function TViewParameters.vars() : TStrings;
    begin
        result := keys;
    end;

    function TViewParameters.getVar(const varName : shortstring) : string;
    var param : PValue;
    begin
        param := keyValueMap.find(varName);
        if (param <> nil) then
        begin
            result := param^.data;
        end else
        begin
            raise EKeyNotFound.createFmt(sKeyNotFound, [varName]);
        end;
    end;

    function TViewParameters.setVar(
        const varName : shortstring;
        const valueData :string
    ) : IViewParameters;
    var param : PValue;
    begin
        param := keyValueMap.find(varName);
        if (param = nil) then
        begin
            //not exists
            new(param);
            param^.data := valueData;
            keyValueMap.add(varName, param);
            keys.add(varName);
        end else
        begin
            param^.data := valueData;
        end;;
        result := self;
    end;
end.

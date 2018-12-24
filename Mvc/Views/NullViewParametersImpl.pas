{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit NullViewParametersImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    classes,
    ViewParametersIntf,
    InjectableObjectImpl;

type

    (*!------------------------------------------------
     * dummy view parameters implementation
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TNullViewParameters = class(TInjectableObject, IViewParameters)
    private
        keys : TStringList;
    public
        constructor create();
        destructor destroy(); override;

        (*!------------------------------------------------
         * get all registered variable name as array of string
         *-----------------------------------------------
         * @return instance of TStrings
         *-----------------------------------------------
         * Note: caller MUST not modify or destroy TStrings
         * instance and should read only
         *-----------------------------------------------*)
        function vars() : TStrings;

        (*!------------------------------------------------
         * get variable value by name
         *-----------------------------------------------
         * @param varName name of variable
         * @return value of variable
         *-----------------------------------------------*)
        function getVar(const varName : shortstring) : string;

        (*!------------------------------------------------
         * set variable value by name
         *-----------------------------------------------
         * @param varName name of variable
         * @param valueData value to be store
         * @return current class instance
         *-----------------------------------------------*)
        function setVar(const varName : shortstring; const valueData :string) : IViewParameters;
    end;

implementation


    constructor TNullViewParameters.create();
    begin
        keys := TStringList.create();
    end;

    destructor TViewParameters.destroy();
    begin
        inherited destroy();
        keys.free();
    end;

    (*!------------------------------------------------
     * get all registered variable name as array of string
     *-----------------------------------------------
     * @return instance of TStrings
     *-----------------------------------------------
     * Note: caller MUST not modify or destroy TStrings
     * instance and should read only
     *-----------------------------------------------*)
    function TViewParameters.vars() : TStrings;
    begin
        result := keys;
    end;

    (*!------------------------------------------------
     * get variable value by name
     *-----------------------------------------------
     * @param varName name of variable
     * @return value of variable
     *-----------------------------------------------*)
    function TViewParameters.getVar(const varName : shortstring) : string;
    begin
        //intentionally does nothing and always return empty string
        result := '';
    end;

    (*!------------------------------------------------
     * set variable value by name
     *-----------------------------------------------
     * @param varName name of variable
     * @param valueData value to be store
     * @return current class instance
     *-----------------------------------------------*)
    function TViewParameters.setVar(
        const varName : shortstring;
        const valueData :string
    ) : IViewParameters;
    begin
        //intentionally does nothing
        result := self;
    end;
end.

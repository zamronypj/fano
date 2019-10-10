{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit GetOptsParamsIntf;

interface

{$MODE OBJFPC}
{$H+}

uses

    getopts,
    Classes,
    CliParamsIntf,
    CliParamsFactoryIntf;

type

    (*!------------------------------------------------
     * basic class having capability to read
     * command line parameter options using getopt()
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TGetOptsParams = class(TInterfacedObject, ICliParameters, ICliParametersFactory)
    private
        fOptions : TStringList;
        fOpts : array of TOption;
        fOptCount : integer;
        procedure buildOptions();
    public
        constructor create();
        destructor destroy(); override;

        (*!------------------------------------------------
         * get option from command line parameters
         *-----------------------------------------------
         * @param opt option
         * @return value
         *-----------------------------------------------*)
        function getOption(const opt : string; const defValue : string) : string;

        (*!------------------------------------------------
         * test if option is set
         *-----------------------------------------------
         * @param opt option
         * @return boolean
         *-----------------------------------------------*)
        function hasOption(const opt : string) : boolean;

        (*!------------------------------------------------
         * add option
         *-----------------------------------------------
         * @param aName option name
         * @param hasArg flag if option has argument
         * @param aFlag flag if option has argument
         * @param aValue short option
         * @return current instance
         *-----------------------------------------------*)
        function addOption(
            const aName : string;
            const hasArg: integer = 0;
            const aFlag : pchar = nil;
            const aValue: char = #0
        ) : ICliParametersFactory;

        function build() : ICliParameters;
    end;

implementation

    constructor TGetOptsParams.create();
    begin
        fOptions := TStringList.create();
        setLength(fOpts, 10);
        fOptCount := 0;
    end;

    destructor TGetOptsParams.destroy();
    begin
        fOptions.free();
        setLength(fOpts, 0);
        fOpts := nil;
        fOptCount := 0;
        inherited destroy();
    end;

    procedure TGetOptsParams.buildOptions();
    var c : char;
        optionIndex : longint;
    begin
        c:=#0;
        repeat
            c := getLongOpts('', @fOpts[0], optionIndex);
            if c = #0 then
            begin
                if (fOpts[optionIndex].has_arg > 0) then
                begin
                    fOptions.add(fOpts[optionIndex].name + '=' + optarg);
                end else
                begin
                    fOptions.add(fOpts[optionIndex].name);
                end;
            end;
            if (c = '?') or (c = ':') then
            begin
                raise Exception.createFmt('Error with option %s', [optopt]);
            end;
        until c = EndOfOptions;
    end;

    (*!------------------------------------------------
     * get option from command line parameters
     *-----------------------------------------------
     * @param opt option
     * @return value
     *-----------------------------------------------*)
    function TGetOptsParams.getOption(const opt : string; const defValue : string) : string;
    var indx : integer;
    begin
        indx := fOptions.indexOfName(opt);
        if indx > -1 then
        begin
            result := fOptions.valueFromIndex(indx);
        end else
        begin
            result := defValue;
        end;
    end;

    (*!------------------------------------------------
     * test if option is set
     *-----------------------------------------------
     * @param opt option
     * @return boolean
     *-----------------------------------------------*)
    function TGetOptsParams.hasOption(const opt : string) : boolean;
    begin
        result (fOptions.indexOfName(opt) > -1);
    end;

    (*!------------------------------------------------
     * add option
     *-----------------------------------------------
     * @param aName option name
     * @param hasArg flag if option has argument
     * @param aFlag flag if option has argument
     * @param aValue short option
     * @return current instance
     *-----------------------------------------------*)
    function TGetOptsParams.addOption(
        const aName : string;
        const hasArg: integer = 0;
        const aFlag : pchar = nil;
        const aValue: char = #0
    ) : ICliParametersFactory;
    var currLen : integer;
    begin
        currLen := length(fOpts);
        if (fOptCount < currLen - 1) then
        begin
            setLength(fOpts, currLen + 10);
        end;
        fOpts[fOptCount].setOption(aName, hasArg, aFlag, aValue);
        inc(fOptCount);
        result := self;
    end;

    function TGetOptsParams.build() : ICliParameters;
    var currLen : integer;
    begin
        currLen := length(fOpts);
        if (fOptCount < currLen) then
        begin
            setLength(fOpts, fOptCount);
        end;
        buildOptions();
        result := self;
    end;
end.

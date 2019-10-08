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
    CommandLineParamsIntf,
    CommandLineParamsFactoryIntf;

type

    (*!------------------------------------------------
     * basic class having capability to read
     * command line parameter options using getopt()
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TGetOptsParams = class(TInterfacedObject, ICommandLineParameters, ICommandLineParametersFactory)
    private
        fOptions : TStringList;
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
        ) : ICommandLineParametersFactory;

        function build() : ICommandLineParameters;
    end;

implementation

    constructor TGetOptsParams.create();
    begin
        fOptions := TStringList.create();
        buildOptions();
    end;

    destructor TGetOptsParams.destroy();
    begin
        fOptions.free();
        inherited destroy();
    end;

    procedure TGetOptsParams.buildOptions();
    begin

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
    ) : ICommandLineParametersFactory;
    var opt : TOption;
    begin
        opt.setOption(aName, hasArg, aFlag, aValue);
        result := self;
    end;

    function TGetOptsParams.build() : ICommandLineParameters;
    begin
        result := self;
    end;
end.

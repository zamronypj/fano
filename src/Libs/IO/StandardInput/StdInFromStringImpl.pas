{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit StdInFromStringImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    sysutils,
    InjectableObjectImpl,
    StdInReaderIntf;

type

    (*!------------------------------------------------
     * class simulate that read standard input to string
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TStdInFromString = class(TInjectableObject, IStdInReader)
    private
        fInputStr : string;
    public
        constructor create(const inputStr : string);
        function readStdIn(const contentLength : int64) : string;
    end;

implementation

    constructor TStdInFromString.create(const inputStr : string);
    begin
        fInputStr := inputStr;
    end;

    function TStdInFromString.readStdIn(const contentLength : int64) : string;
    begin
        result := copy(fInputStr, 1, contentLength);
    end;
end.

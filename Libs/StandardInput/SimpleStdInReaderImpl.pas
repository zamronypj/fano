{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit SimpleStdInReaderImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    sysutils,
    InjectableObjectImpl,
    StdInReaderIntf;

type

    (*!------------------------------------------------
     * class that read standard input to string
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TSimpleStdInReader = class(TInjectableObject, IStdInReader)
    public
        function readStdIn(const contentLength : int64) : string;
    end;

implementation

    function TSimpleStdInReader.readStdIn(const contentLength : int64) : string;
    var ctr : int64;
        ch : char;
    begin
        //read STDIN
        ctr := 0;
        setLength(result, contentLength);
        while (ctr < contentLength) do
        begin
            read(ch);
            result[ctr+1] := ch;
            inc(ctr);
        end;
    end;
end.

{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit StdInFromStreamImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    sysutils,
    InjectableObjectImpl,
    StreamAdapterIntf,
    StdInReaderIntf;

type

    (*!------------------------------------------------
     * class simulate that read standard input from stream
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TStdInFromStream = class(TInjectableObject, IStdInReader)
    private
        fInputStream : IStreamAdapter;
    public
        constructor create(const inputStream : IStreamAdapter);
        function readStdIn(const contentLength : int64) : string;
    end;

implementation

    constructor TStdInFromStream.create(const inputStream : IStreamAdapter);
    begin
        fInputStream := inputStream;
    end;

    function TStdInFromStream.readStdIn(const contentLength : int64) : string;
    begin
        setLength(result, contentLength);
        fInputStream.readBuffer(result[1], contentLength);
    end;
end.

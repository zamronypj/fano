{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit StdInReaderImpl;

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
    TStdInReader = class(TInjectableObject, IStdInReader)
    public
        function readStdIn(const contentLength : int64) : string;
    end;

implementation

uses

    classes,
    iostream;

    function TStdInReader.readStdIn(const contentLength : int64) : string;
    const BUFFER_SIZE = 8 * 1024;
    var tmpBuffer : pointer;
        totalRead, readCount : int64;
        inputStream : TIOStream;
        buff : TStringStream;
    begin
        getmem(tmpBuffer, BUFFER_SIZE);
        inputStream := TIOStream.create(iosInput);
        buff := TStringStream.create('');
        try
            //preallocated so we can avoid allocate/deallocate inside loop
            buff.size := contentLength;
            readCount := 0;
            while (readCount < contentLength) do
            begin
                totalRead := inputStream.read(tmpBuffer^, BUFFER_SIZE);
                buff.write(tmpBuffer^, totalRead);
                inc(readCount, totalRead);
            end;
            result := buff.dataString;
        finally
            freemem(tmpBuffer, BUFFER_SIZE);
            freeAndNil(buff);
            freeAndNil(inputStream);
        end;
    end;
end.

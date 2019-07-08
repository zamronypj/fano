{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit CloseableStreamImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    Classes,
    StreamAdapterIntf,
    CloseableIntf;

type

    (*!-----------------------------------------------
     * stream implementation that read/write socket and
     * can be close
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TCloseableStream = class(TInterfacedObject, IStreamAdapter, ICloseable)
    private
        fHandle : THandle;
        fStream : IStreamAdapter;
    public
        constructor create(const ahandle: THandle; const aStream : IStreamAdapter);
        destructor destroy(); override;
        function close() : boolean;

        property stream : IStreamAdapter read fStream implements IStreamAdapter;
    end;

implementation

    constructor TCloseableStream.create(const ahandle: THandle; const aStream : IStreamAdapter);
    begin
        fHandle := aHandle;
        fStream := aStream;
    end;

    destructor TCloseableStream.destroy();
    begin
        inherited destroy();
        fStream := nil;
    end;

    function TCloseableStream.close() : boolean;
    begin
        closeSocket(fHandle);
        result := true;
    end;

end.

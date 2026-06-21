{-------------------------------------------------------------------------------
MIT License

Copyright (c) 2018 - Present Zamrony P. Juhara

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
-------------------------------------------------------------------------------}
unit Response;

{$MODE OBJFPC}
{$H+}

interface

uses

    KeyValue,
    HttpHeaders,
    HasBufferIntf,
    HasConnFdIntf,
    ResponseIntf;

type

   { TResponse }

   TResponse = class(TInterfacedObject, IResponse, IHasBuffer, IHasConnFd)
   protected
       {$IFDEF WINDOWS}
       fConnfd: TSocket;
       {$ELSE}
       fConnfd: longint;
       {$ENDIF}

       fHeaders: THttpHeaders;
       fBuffer: TStream;
   public
       constructor Create(
           {$IFDEF WINDOWS}
           aconnfd: TSocket
           {$ELSE}
           aconnfd: longint
           {$ENDIF}
       );
       destructor Destroy; override;
       function getHeaders(): THeaders; virtual;
       function getBuffer(): TStream; virtual;
       procedure write(const astr: string); virtual;
       procedure send(); virtual;
       procedure sendEnd(); virtual;

       property buffer: TStream read getBuffer;

       {$IFDEF WINDOWS}
       function getConnFd(): TSocket;
       property fd: TSocket read getConnFd;
       {$ELSE}
       function getConnFd(): longint;
       property fd: longint read getConnFd;
       {$ENDIF}
   end;


implementation

{ TResponse }

constructor TResponse.Create(
    {$IFDEF WINDOWS}
    aconnfd: TSocket
    {$ELSE}
    aconnfd: longint
    {$ENDIF}
);
begin
    fConnfd := aconnfd;
    fHeaders := THttpHeaders.Create();
    fBuffer := TMemoryStream.Create();
end;

destructor TResponse.Destroy;
begin
    fHeaders.Free();
    fBuffer.Free();
    inherited Destroy;
end;

function TResponse.getHeaders(): THeaders;
begin
    result := fHeaders;
end;

function TResponse.getBuffer(): TStream;
begin
    result := fBuffer;
end;

procedure TResponse.write(const astr: string);
begin
    fBuffer.WriteBuffer(astr[1], length(astr));
end;

procedure TResponse.send();
begin
    //
end;

procedure TResponse.sendEnd();
begin

end;

{$IFDEF WINDOWS}
function TResponse.getConnFd(): TSocket;
begin
    result := fConnfd;
end;
{$ELSE}
function TResponse.getConnFd(): longint;
begin
    result := fConnfd;
end;
{$ENDIF}

end.

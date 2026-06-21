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
unit Request;

{$MODE OBJFPC}
{$H+}

interface

uses

    classes,
    KeyValue,
    uhttp,
    RequestIntf;

type

    { TRequest }

    TRequest = class(TInterfacedObject, IRequest)
    private
        fMethod: THttpMethod;
        fHeaders: THttpHeaders;
        fUploadedFiles : TUploadedFiles;
    public
        constructor create(aMethod: THttpMethod;
            aUrl: string;
            aHeaders: THttpHeaders;
            aRouteParams: TKeyValue;
            aParams: TKeyValue;
            aUploadedFiles: TUploadedFiles);
        destructor Destroy(); override;

        function getMethod: THttpMethod; virtual;
        function getHeaders(): THttpHeaders; virtual;

        // retrieve route parameter
        // for example for route defined as /my-resources/{id}
        // when URL is /my-resources/1
        // then getRouteParams()['id'] equals '1'
        function getRouteParams(): TKeyValue; virtual;

        // retrieve query strings parameters or body parameters if any
        function getParams(): TKeyValue; virtual;

        // retrieve uploaded files if any
        function getUploadedFiles(): TUploadedFiles; virtual;

        property method: THttpMethod read getMethod;
        property headers:THeaders read getHeaders;
        property routeParams:TKeyValue read getRouteParams;
        property params:TKeyValue read getParams;
        property uploadedFiles: TUploadedFiles read getUploadedFiles;
    end;

implementation

{ TRequest }

constructor TRequest.create(aMethod: THttpMethod;
    aUrl: string;
    aHeaders: THttpHeaders;
    aRouteParams: TKeyValue;
    aParams: TKeyValue;
    aUploadedFiles: TUploadedFiles);
var i: integer;
begin
    fMethod := aMethod;
    fHeaders := aHeaders;
    fRouteParams := aRouteParams;
    fParams := aParams;
    fUploadedFiles := aUploadedFiles;
end;


destructor TRequest.Destroy();
begin
    fHeaders.Free;
    fRouteParams.Free;
    fParams.Free;
    fUploadedFiles := nil;
    inherited Destroy();
end;

function TRequest.getMethod: THttpMethod;
begin
    result := fMethod;
end;

function TRequest.getHeaders(): THttpHeaders;
begin
    result := fHeaders;
end;

function TRequest.getRouteParams(): TKeyValue;
begin
    result := fRouteParams;
end;

function TRequest.getParams(): TKeyValue;
begin
    result := fParams;
end;

function TRequest.getUploadedFiles(): TUploadedFiles;
begin
    result := fUploadedFiles;
end;

end.

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
uses RequestIntf;

{$MODE OBJFPC}
{$H+}

interface

uses

    uhttp,
    KeyValue,
    HttpHeaders;

type

    IRequest = interface
        ['{8A66641D-CA81-4F3C-8194-D861EC683BB9}']
        function getMethod: THttpMethod;
        function getHeaders(): THeaders;
        function getRouteParams(): TKeyValue;

        // retrieve query strings parameters or body parameters if any
        function getParams(): TKeyValue;

        // retrieve uploaded files if any
        function getUploadedFiles(): TUploadedFiles;

        property method: THttpMethod read getMethod;
        property headers:THeaders read getHeaders;
        property routeParams:TKeyValue read getRouteParams;
        property params:TKeyValue read getParams;
        property uploadedFiles: TUploadedFiles read getUploadedFiles;
    end;

implementation

end.

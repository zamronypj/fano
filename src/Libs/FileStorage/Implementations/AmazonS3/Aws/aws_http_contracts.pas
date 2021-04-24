{
  MIT License

  Copyright (c) 2013-2019 Marcos Douglas B. Santos
  Copyright (c) 2021 Zamrony P. Juhara

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
}
unit aws_http_contracts;

{$i aws.inc}

interface

uses
    sysutils,
    classes,
    aws_stream;

type

    IHTTPRequest = interface(IInterface)
        ['{12744C05-22B6-45BF-B47A-49813F6B64B6}']
        function Method: string;
        function SubDomain: string;
        function Domain: string;
        function Resource: string;
        function SubResource: string;
        function ContentType: string;
        function ContentMD5: string;
        function CanonicalizedAmzHeaders: string;
        function CanonicalizedResource: string;
        function Stream: IAWSStream;
        function AsString: string;
    end;

    IHTTPResponse = interface(IInterface)
        ['{6E7E8524-88B5-48B1-95FF-30D0DF40D8F7}']
        function Code: Integer;
        function Header: string;
        function Text: string;
        function Stream: IAWSStream;
    end;

    IHTTPSender = interface(IInterface)
        ['{DF9B2674-D60C-4F40-AD6A-AE158091212D}']
        function Send: IHTTPResponse;
    end;


implementation

end.

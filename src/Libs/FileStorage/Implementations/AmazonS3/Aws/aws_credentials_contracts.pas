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
unit aws_credentials_contracts;

{$i aws.inc}

interface

uses

    sysutils,
    classes,
    aws_http_contracts;

type

    IAWSSignatureHMAC256 = interface(IInterface)
        ['{9158D9A2-7ABA-4126-9F63-264E947AC60A}']
        function AccessKey: string;
        function DataStamp: string;
        function RegionName: string;
        function ServiceName: string;
        function Signature: TBytes;
    end;

    IAWSCredentials = interface(IInterface)
        ['{AC6EA523-F2FF-4BD0-8C87-C27E9846FA40}']
        function AccessKeyId: string;
        function SecretKey: string;
        function UseSSL: Boolean;
    end;

    IAWSSignature = interface
        function Credentials: IAWSCredentials;
        function Calculate(Request: IHTTPRequest): string;
    end;

implementation


end.

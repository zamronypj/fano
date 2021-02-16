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
unit aws_client;

{$i aws.inc}

interface

uses

    sysutils,
    classes,
    aws_credentials_contracts,
    aws_http_contracts,
    aws_http,
    aws_client_contracts,
    aws_http_sender;

type
    TAWSRequest = THTTPRequest;

    TAWSResponse = THTTPResponse;

    TAWSClient = class sealed(TInterfacedObject, IAWSClient)
    private
        FSignature: IAWSSignature;
        function MakeURL(const SubDomain, Domain, Query: string): string;
    public
        constructor Create(Signature: IAWSSignature);
        class function new(Signature: IAWSSignature): IAWSClient;
        function send(Request: IAWSRequest): IAWSResponse;
    end;

implementation

    { TAWSClient }

    function TAWSClient.MakeURL(const SubDomain, Domain, Query: string): string;
    begin
        Result := '';
        if FSignature.Credentials.UseSSL then
        begin
            result += 'https://';
        end else
        begin
            result += 'http://';
        end;

        if SubDomain <> '' then
        begin
            result += SubDomain + '.';
        end;
        result += Domain + Query;
    end;

    constructor TAWSClient.create(Signature: IAWSSignature);
    begin
        inherited Create;
        FSignature := Signature;
    end;

    class function TAWSClient.new(Signature: IAWSSignature): IAWSClient;
    begin
        result := Create(Signature);
    end;

    function TAWSClient.send(Request: IAWSRequest): IAWSResponse;
    begin
        result := THTTPSender.New(
            Request.Method,
            FSignature.Calculate(Request),
            Request.ContentType,
            MakeURL(Request.SubDomain, Request.Domain, Request.Resource),
            Request.Stream
        ).send();
    end;

end.

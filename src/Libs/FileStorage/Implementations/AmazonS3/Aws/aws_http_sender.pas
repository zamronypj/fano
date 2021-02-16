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
unit aws_http_sender;

{$i aws.inc}

interface

uses

    sysutils,
    classes,
    aws_base,
    aws_http_contracts,
    fphttpclient,
    fpopenssl,
    openssl;

type

  THTTPSender = class sealed(TInterfacedObject, IHTTPSender)
  private
    FSender: TFpHttpClient;
    FMethod: string;
    FHeader: string;
    FContentType: string;
    FURL: string;
    FStream: IAWSStream;
    procedure setupHeaders(const httpClient: TFpHttpClient; const header : string);
  public
    constructor Create(const Method, Header, ContentType, URL: string; Stream: IAWSStream);
    class function New(const Method, Header, ContentType, URL: string; Stream: IAWSStream): IHTTPSender;
    destructor Destroy; override;
    function Send: IHTTPResponse;
  end;

implementation


{ THTTPSender }

constructor THTTPSender.Create(const Method, Header, ContentType, URL: string;
  Stream: IAWSStream);
begin
    inherited Create;
    FSender := TFPHTTPClient.Create(nil);
    FMethod := Method;
    FHeader := Header;
    FContentType := ContentType;
    FURL := URL;
    FStream := Stream;
end;

class function THTTPSender.New(const Method, Header, ContentType, URL: string;
  Stream: IAWSStream): IHTTPSender;
begin
    Result := Create(Method, Header, ContentType, URL, Stream);
end;

destructor THTTPSender.Destroy;
begin
    FSender.Free;
    inherited Destroy;
end;

function THTTPSender.Send: IHTTPResponse;
begin
    FSender.RequestHeaders.Clear;
    FSender.RequestHeaders.Text := FHeader;
    FSender.RequestBody.Size := 0;
    FSender.MimeType := FContentType;
    FStream.SaveToStream(FSender.Document);
    FSender.HTTPMethod(FMethod, FURL);
    result := THTTPResponse.New(
        FSender.ResponseStatusCode,
        FSender.ResponseHeaders.Text,
        FSender.ResultString,
        TAWSStream.New(FSender.Document)
    );
end;

end.

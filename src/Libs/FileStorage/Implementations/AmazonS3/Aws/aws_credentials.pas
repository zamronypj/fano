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
unit aws_credentials;

{$i aws.inc}

interface

uses
    sysutils,
    classes,
    dateutils,
    aws_http_contracts,
    aws_credentials_contracts,
    aws_utils;

type

    { TAWSSignatureHMAC256 }

    TAWSSignatureHMAC256 = class sealed(TInterfacedObject, IAWSSignatureHMAC256)
    private
        FAccessKey: string;
        FDataStamp: string;
        FRegionName: string;
        FServiceName: string;
    public
        constructor Create(const AccessKey, DataStamp, RegionName, ServiceName: string);
        class function New(const AccessKey, DataStamp, RegionName, ServiceName: string): IAWSSignatureHMAC256;
        function AccessKey: string;
        function DataStamp: string;
        function RegionName: string;
        function ServiceName: string;
        function Signature: TBytes;
    end;

    TAWSCredentials = class sealed(TInterfacedObject, IAWSCredentials)
    private
        FAccessKeyId: string;
        FSecretKey: string;
        FSSL: Boolean;
    public
        constructor Create(
          const AccessKeyId, SecretKey: string;
          UseSSL: Boolean); reintroduce;
        class function New(
          const AccessKeyId, SecretKey: string;
          UseSSL: Boolean): IAWSCredentials;
        function AccessKeyId: string;
        function SecretKey: string;
        function UseSSL: Boolean;
    end;

    TAWSAbstractSignature = class abstract(TInterfacedObject, IAWSSignature)
    strict private
      FCredentials: IAWSCredentials;
    public
      constructor Create(Credentials: IAWSCredentials);
      class function New(Credentials: IAWSCredentials): IAWSSignature;
      function Credentials: IAWSCredentials;
      function Calculate(Request: IHTTPRequest): string; virtual; abstract;
    end;

    TAWSSignatureVersion1 = class sealed(TAWSAbstractSignature)
    public
      function Calculate(Request: IHTTPRequest): string; override;
    end;

    TAWSSignatureVersion3 = class sealed(TAWSAbstractSignature)
    public
      function Calculate(Request: IHTTPRequest): string; override;
    end;

    { TAWSSignatureVersion4 }

    TAWSSignatureVersion4 = class sealed(TAWSAbstractSignature)
    private
      function BuildHeader(const Header: String): String;
      procedure SignedHeaders(const Header: String; var ToSing, ToCanonical: String);
    public
      function Calculate(Request: IHTTPRequest): string; override;
    end;

implementation

uses

    HlpIHashInfo,
    HlpConverters,
    HlpIHashResult,
    HlpHashFactory,
    HlpIHash,
    httpprotocol,
    base64,
    hmac;

    { TAWSSignatureHMAC256 }

    constructor TAWSSignatureHMAC256.Create(const AccessKey, DataStamp,
      RegionName, ServiceName: string);
    begin
        inherited Create;
        FAccessKey:= AccessKey;
        FDataStamp:= DataStamp;
        FRegionName:= RegionName;
        FServiceName:= ServiceName;
    end;

    class function TAWSSignatureHMAC256.New(const AccessKey, DataStamp,
      RegionName, ServiceName: string): IAWSSignatureHMAC256;
    begin
        Result := Create(AccessKey, DataStamp, RegionName, ServiceName);
    end;

    function TAWSSignatureHMAC256.AccessKey: string;
    begin
        Result := FAccessKey;
    end;

    function TAWSSignatureHMAC256.DataStamp: string;
    begin
        Result := FDataStamp;
    end;

    function TAWSSignatureHMAC256.RegionName: string;
    begin
        Result := FRegionName;
    end;

    function TAWSSignatureHMAC256.ServiceName: string;
    begin
        Result := FServiceName;
    end;

    function TAWSSignatureHMAC256.Signature: TBytes;
    var
        res : IHashResult;
        hmacInst : IHMAC;
    begin
        hmacInst := THashFactory.THMAC.CreateHMAC(
            THashFactory.TCrypto.CreateSHA2_256
        );
        hmacInst.Key := TConverters.ConvertStringToBytes('AWS4' + FAccessKey, TEncoding.UTF8);
        res := hmacInst.ComputeString(FDataStamp, TEncoding.UTF8);
        hmacInst.Key := res.getBytes();
        res := hmacInst.ComputeString(FRegionName, TEncoding.UTF8);
        hmacInst.Key := res.getBytes();
        res := hmacInst.ComputeString(FServiceName, TEncoding.UTF8);
        hmacInst.Key := res.getBytes();
        res := hmacInst.ComputeString('aws4_request', TEncoding.UTF8);
        result := res.getBytes();
    end;

    { TAWSSignatureVersion4 }

    function TAWSSignatureVersion4.BuildHeader(const Header: String): String;
    var
        i: Integer;
        list: TStringList;
    begin
        list := TStringList.Create;
        try
          list.Text := Header;
          list.LineBreak := #10;
          list.NameValueSeparator := ':';
          list.Sorted:=True;
          list.Sort;
          result := '';
          for i := 1 to list.Count - 1 do
          begin
              Result := Result + List[i] + #10;
          end;
        finally
            list.free();
        end;
    end;

    procedure TAWSSignatureVersion4.SignedHeaders(const Header: String; var ToSing, ToCanonical: String);
    var
        i: Integer;
        List: TStringList;
        Name, Value: String;
    begin
        List := TStringList.Create;
        List.Text:=Header;
        List.LineBreak:=#10;
        List.NameValueSeparator:=':';
        List.Sorted:=True;
        List.Sort;
        for i := 1 to List.Count - 1 do
          begin
            List.GetNameValue(i, Name, Value);
            ToSing := ToSing + LowerCase(Name) + ';';
            ToCanonical := ToCanonical + LowerCase(Name)+':'+Value+#10;
          end;
        system.Delete(ToSing, Length(ToSing), 1);
    end;

    function TAWSSignatureVersion4.Calculate(Request: IHTTPRequest): string;
    const
        Algoritimo = 'AWS4-HMAC-SHA256';
        TipoReq = 'aws4_request';
    var
        Header: string;
        Credencial: String;
        Escopo: String;
        DateFmt: String;
        AwsDateTime: String;
        Metodo: String;
        Canonical: String;
        CanonicalURI: String;
        CanonicalQuery: String;
        CanonicalHeaders: String;
        SignedHeader: String;
        PayLoadHash: String;
        CanonicalRequest: String;
        StringToSign: String;
        Signature: String;
        AuthorizationHeader: String;
        Assinatura: TBytes;
        hmacInst : IHMAC;

        hashSHA256Inst : IHash;
    begin
        hashSHA256Inst := THashFactory.TCrypto.CreateSHA2_256();

        DateFmt:= FormatDateTime('yyyymmdd', IncHour(Now, 3));
        AwsDateTime:= FormatDateTime('yyyymmdd', IncHour(Now, 3))+'T'+FormatDateTime('hhnnss', IncHour(Now, 3))+'Z';
        Metodo:= Request.Method;
        CanonicalURI := urlEncodeChars(Request.Resource, [':']);
        CanonicalQuery:='';

        Header := 'Host:' + Request.Domain + #10 ;
        CanonicalHeaders:= 'X-Amz-Date:' + AwsDateTime + #10 + Request.CanonicalizedAmzHeaders + #10;
        SignedHeaders(Header+CanonicalHeaders, SignedHeader, Canonical);

        //compute SHA2-256
        PayLoadHash := hashSHA256Inst.ComputeString(Request.SubResource, TEncoding.UTF8).toString();

        CanonicalRequest := Metodo + #10 + CanonicalURI + #10 + CanonicalQuery + #10
                          + Canonical + #10 + SignedHeader + #10 + PayLoadHash;

        Credencial:= DateFmt + '/' + Request.ContentMD5 + '/' + Request.CanonicalizedResource + '/' + TipoReq;
        Escopo:= Credentials.AccessKeyId + '/' + Credencial;
        StringToSign := Algoritimo + #10 +  AwsDateTime + #10 + Credencial + #10 +
            //compute SHA256
            hashSHA256Inst.ComputeString(CanonicalRequest, TEncoding.UTF8).toString();

        Assinatura:=TAWSSignatureHMAC256.New(Credentials.SecretKey, DateFmt, Request.ContentMD5, Request.CanonicalizedResource).Signature;

        hmacInst := THashFactory.THMAC.CreateHMAC(THashFactory.TCrypto.CreateSHA2_256());

        hmacInst.Key := Assinatura;
        signature := hmacInst.ComputeString(StringToSign, TEncoding.UTF8).toString();

        AuthorizationHeader := 'Authorization:' + Algoritimo + ' ' + 'Credential=' + Escopo + ', ' +
                              'SignedHeaders=' + SignedHeader + ', ' + 'Signature=' + Signature;

        result := BuildHeader(CanonicalHeaders) + AuthorizationHeader;
    end;

    { TAWSCredentials }

    constructor TAWSCredentials.Create(const AccessKeyId, SecretKey: string;
      UseSSL: Boolean);
    begin
      FAccessKeyId := AccessKeyId;
      FSecretKey := SecretKey;
      FSSL := UseSSL;
    end;

    class function TAWSCredentials.New(const AccessKeyId, SecretKey: string;
      UseSSL: Boolean): IAWSCredentials;
    begin
      Result := Create(AccessKeyId, SecretKey, UseSSL);
    end;

    function TAWSCredentials.AccessKeyId: string;
    begin
      Result := FAccessKeyId;
    end;

    function TAWSCredentials.SecretKey: string;
    begin
      Result := FSecretKey;
    end;

    function TAWSCredentials.UseSSL: Boolean;
    begin
      Result := FSSL;
    end;

    { TAWSAbstractSignature }

    constructor TAWSAbstractSignature.Create(Credentials: IAWSCredentials);
    begin
      inherited Create;
      FCredentials := Credentials;
    end;

    class function TAWSAbstractSignature.New(
      Credentials: IAWSCredentials): IAWSSignature;
    begin
      Result := Create(Credentials);
    end;

    function TAWSAbstractSignature.Credentials: IAWSCredentials;
    begin
      Result := FCredentials;
    end;

    { TAWSSignatureVersion1 }

    function DateFormatRFC822(dt: TDateTime; const timezone : string) : string;
    var
        aYear, aMonth, aDay: word;
        aHour, aMinute, aSec, aMSec : word;
    begin
        DecodeDate(dt, aYear, aMonth, aDay);
        DecodeTime(dt, aHour, aMinute, aSec, aMsec);
        result := Format(
            '%s, %d %s %d %0d:%0d:%0d %s',
            [
                HTTPDays[DayOfWeek(dt)],
                aDay,
                HTTPMonths[aMonth],
                aYear,
                aHour,
                aMinute,
                aSec,
                timezone
            ]
        );
    end;

    function TAWSSignatureVersion1.Calculate(Request: IHTTPRequest): string;
    var
      H: string;
      DateFmt: string;
    begin
      DateFmt := DateFormatRFC822(Now, 'GMT');
      H := Request.Method + #10
        + Request.ContentMD5 + #10
        + Request.ContentType + #10
        + DateFmt + #10;

      if Request.CanonicalizedAmzHeaders <> EmptyStr then
        H := H + Request.CanonicalizedAmzHeaders + #10;

      H := H + Request.CanonicalizedResource;

      Result := 'Date: ' + DateFmt + #10;

      if Request.CanonicalizedAmzHeaders <> EmptyStr then
        Result := Result + Request.CanonicalizedAmzHeaders + #10;

      Result := Result + 'Authorization: AWS '
              + Credentials.AccessKeyId + ':'
              + EncodeStringBase64(HMACSHA1(Credentials.SecretKey, H))
    end;

    { TAWSSignatureVersion3 }

    function TAWSSignatureVersion3.Calculate(Request: IHTTPRequest): string;
    var
      DateFmt: string;
    begin
      DateFmt := DateFormatRFC822(Now, 'GMT');
      Result := 'Date: ' + DateFmt + #10
              + 'Host: ' + Request.Domain + #10
              + 'X-Amzn-Authorization: '
              + 'AWS3-HTTPS AWSAccessKeyId=' + Credentials.AccessKeyId + ','
              + 'Algorithm=HMACSHA1,Signature='+EncodeStringBase64(HMACSHA1(Credentials.SecretKey, DateFmt));
    end;

end.
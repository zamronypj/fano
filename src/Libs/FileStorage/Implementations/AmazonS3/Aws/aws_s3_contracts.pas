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
unit aws_s3_contracts;

{$i aws.inc}

interface

uses
    //rtl
    classes,
    sysutils,
    aws_stream,
    aws_http_contracts,
    aws_client_contracts,
    aws_client;

const

    AWS_S3_URL = 'amazonaws.com';

type

    IS3Service = interface;
    IS3Bucket = interface;

    IS3Object = interface(IInterface)
        ['{FF865D65-97EE-46BC-A1A6-9D9FFE6310A4}']
        function Bucket: IS3Bucket;
        function Name: string;
        function Stream: IAWSStream;
    end;

    IS3Objects = interface(IInterface)
        ['{0CDE7D8E-BA30-4FD4-8FC0-F8291131652E}']
        function Get(const ObjectName: string; const SubResources: string): IS3Object;
        procedure Delete(const ObjectName: string);
        function Put(const ObjectName, ContentType: string; Stream: IAWSStream; const SubResources: string): IS3Object;
        function Put(const ObjectName, ContentType, AFileName, SubResources: string): IS3Object;
        function Put(const ObjectName, SubResources: string): IS3Object;
        function Options(const ObjectName: string): IS3Object;
        function listObjects(const objectName : string; const delimiter : string) : IS3Objects;
    end;

    IS3Bucket = interface(IInterface)
        ['{7E7FA31D-7F54-4BE0-8587-3A72E7D24164}']
        function Name: string;
        function Objects: IS3Objects;
    end;

    IS3Buckets = interface(IInterface)
        ['{8F994521-57A1-4FA6-9F9F-3931E834EFE2}']
        function Check(const BucketName: string): Boolean;
        function Get(const BucketName, SubResources: string): IS3Bucket;
        procedure Delete(const BucketName, SubResources: string);
        function Put(const BucketName, SubResources: string): IS3Bucket;
        { TODO : Return a Bucket list }
        function All: IAWSResponse;
    end;

    IS3Service = interface(IInterface)
        ['{B192DB11-4080-477A-80D4-41698832F492}']
        function Online: Boolean;
        function Buckets: IS3Buckets;
    end;


implementation

end.

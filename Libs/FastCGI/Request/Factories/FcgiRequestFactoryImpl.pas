{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FcgiRequestFactoryImpl;

interface

{$MODE OBJFPC}

uses

    EnvironmentIntf,
    RequestIntf,
    RequestFactoryIntf,
    FcgiProcessorIntf;

type
    (*!------------------------------------------------
     * factory class for FastCGI Request
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiRequestFactory = class(TInterfacedObject, IRequestFactory)
    private
        fcgiProcessor : IFcgiProcessor;
    public
        constructor create(const afcgiProc : IFcgiProcessor);
        destructor destroy; override;
        function build(const env : ICGIEnvironment) : IRequest;
    end;

implementation

uses
    RequestImpl,
    HashListImpl,
    MultipartFormDataParserImpl,
    UploadedFileCollectionFactoryImpl,
    UploadedFileCollectionWriterFactoryImpl,
    StdInReaderIntf,
    StdInFromStringImpl;

    constructor create(const afcgiProc : IFcgiProcessor);
    begin
        fcgiProcessor := afcgiProc;
    end;

    destructor TFcgiRequestFactory.destroy();
    begin
        inherited destroy();
        fcgiProcessor := nil;
    end;

    function TFcgiRequestFactory.build(const env : ICGIEnvironment) : IRequest;
    var arequest : IRequest;
    begin
        arequest := TRequest.create(
            env,
            THashList.create(),
            THashList.create(),
            THashList.create(),
            TMultipartFormDataParser.create(
                TUploadedFileCollectionWriterFactory.create()
            ),
            TStdInReaderFromString.create(fcgiProcessor.getStdIn())
        );
        result := TFcgiRequest.create(fcgiProcessor.getRequestId(), arequest);
    end;
end.

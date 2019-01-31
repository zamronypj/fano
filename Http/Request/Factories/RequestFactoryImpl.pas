{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit RequestFactoryImpl;

interface

{$MODE OBJFPC}

uses
    EnvironmentIntf,
    RequestIntf,
    RequestFactoryIntf;

type
    (*!------------------------------------------------
     * factory class for TRequest
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TRequestFactory = class(TInterfacedObject, IRequestFactory)
    public
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
    StdInReaderImpl,
    SimpleStdInReaderImpl;

    function TRequestFactory.build(const env : ICGIEnvironment) : IRequest;
    begin
        result := TRequest.create(
            env,
            THashList.create(),
            THashList.create(),
            THashList.create(),
            TMultipartFormDataParser.create(
                TUploadedFileCollectionWriterFactory.create()
            ),
            TStdInReader.create()
        );
    end;
end.

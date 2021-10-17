{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2021 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FpwebRequestFactoryImpl;

interface

{$MODE OBJFPC}

uses
    EnvironmentIntf,
    StdInIntf,
    RequestIntf,
    RequestFactoryIntf;

type
    (*!------------------------------------------------
     * factory class for TRequest
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFpwebRequestFactory = class(TInterfacedObject, IRequestFactory, IFpwebRequestAware)
    private

    public
        function build(const env : ICGIEnvironment; const stdIn : IStdIn) : IRequest;
    end;

implementation

uses

    RequestImpl,
    RequestHeadersImpl,
    HashListImpl,
    MultipartFormDataParserImpl,
    UploadedFileCollectionFactoryImpl,
    UploadedFileCollectionWriterFactoryImpl,
    StdInReaderImpl,
    SimpleStdInReaderImpl,
    UriImpl;

    function TFpwebRequestFactory.build(
        const env : ICGIEnvironment;
        const stdIn : IStdIn
    ) : IRequest;
    begin
        result := TFpWebRequest.create(
            TUri.create(env),
            TRequestHeaders.create(env),
            env,
            stdIn,
            fRequest
        );
    end;
end.

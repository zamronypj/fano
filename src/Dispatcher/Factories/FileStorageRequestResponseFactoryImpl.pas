{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2020 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FileStorageRequestResponseFactoryImpl;

interface

{$MODE OBJFPC}

uses

    RequestFactoryIntf,
    ResponseFactoryIntf,
    RequestResponseFactoryIntf,
    StorageIntf,
    InjectableObjectImpl,
    DecoratorRequestResponseFactoryImpl;

type

    (*!---------------------------------------------------
     * class having capability return request and response
     * factory which use file storage utility
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *---------------------------------------------------*)
    TFileStorageRequestResponseFactory = class(TInjectableObject, IRequestResponseFactory)
    private
        fStorage : IStorage;
    public
        constructor create(const storage : IStorage);
        function getRequestFactory() : IRequestFactory;
        function getResponseFactory() : IResponseFactory;
    end;

implementation

uses

    FileStorageRequestFactoryImpl,
    ResponseFactoryImpl;

    constructor TFileStorageRequestResponseFactory.create(
        const storage : IStorage
    );
    begin
        fStorage := storage;
    end;

    function TFileStorageRequestResponseFactory.getRequestFactory() : IRequestFactory;
    begin
        result := TFileStorageRequestFactory.create(fStorage);
    end;

    function TFileStorageRequestResponseFactory.getResponseFactory() : IResponseFactory;
    begin
        result := TResponseFactory.create();
    end;

end.

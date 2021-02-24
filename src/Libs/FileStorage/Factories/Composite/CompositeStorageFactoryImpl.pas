{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2021 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit CompositeStorageFactoryImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    DependencyIntf,
    DependencyContainerIntf,
    StorageIntf,
    StorageTypes,
    FactoryImpl;

type

    (*!------------------------------------------------
     * factory class for TCompositeStorage
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TCompositeStorageFactory = class(TFactory, IDependencyFactory)
    private
        fStorages : IStorageArray;
    public
        destructor destroy(); override;
        function add(const storage : IStorage) : TCompositeStorageFactory;
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses

    CompositeStorageImpl;

    destructor TCompositeStorageFactory.destroy();
    var i : integer;
    begin
        for i := 0 to Length(fStorages) - 1 do
        begin
            fStorages[i] := nil;
        end;
        inherited destroy();
    end;

    function TCompositeStorageFactory.add(const storage: IStorage) : TCompositeStorageFactory;
    begin
        //this assumes that number of items are pretty small
        setLength(fStorages, length(fStorages) + 1);
        fStorages[length(fStorages) - 1] := storage;
        result := self;
    end;

    function TCompositeStorageFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TCompositeStorage.create(fStorages);
    end;

end.

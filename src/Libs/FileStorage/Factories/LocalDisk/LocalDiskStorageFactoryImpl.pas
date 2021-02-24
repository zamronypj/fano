{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2021 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit LocalDiskStorageFactoryImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl;

type

    (*!------------------------------------------------
     * factory class for TLocalDiskStorage
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TLocalDiskStorageFactory = class(TFactory, IDependencyFactory)
    private
        fBaseDir : string;
    public
        function baseDir(const lBaseDir : string) : TLocalDiskStorageFactory;
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses

    LocalDiskStorageImpl;

    function TLocalDiskStorageFactory.baseDir(const lBaseDir : string) : TLocalDiskStorageFactory;
    begin
        fBaseDir := lBaseDir;
        result := self;
    end;

    function TLocalDiskStorageFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TLocalDiskStorage.create(fBaseDir);
    end;

end.

{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}

unit HeadersFactoryImpl;

interface

uses

    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl;

type
    (*!------------------------------------------------
     * THeaders factory class
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    THeadersFactory = class(TFactory, IDependencyFactory)
    public
        {*!----------------------------------------
         * build instance
         *-----------------------------------------
         * @param container dependency container instance
         * @return instance of IDependency interface
         *------------------------------------------*}
        function build(const container : IDependencyContainer) : IDependency;
    end;

implementation

uses

    HeadersImpl,
    HashListImpl;

    {*!----------------------------------------
     * build instance
     *-----------------------------------------
     * @param container dependency container instance
     * @return instance of IDependency interface
     *------------------------------------------*}
    function THeadersFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := THeaders.create(THashList.create());
    end;

end.

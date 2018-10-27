{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit HeadersFactoryImpl;

interface

{$MODE OBJFPC}

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
        function build(const container : IDependencyContainer) : IDependency; override;
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
        //create headers instance and one default header Content-Type
        result := (THeaders.create(
            THashList.create()
        )).setHeader('Content-Type', 'text/html') as IDependency;
    end;

end.

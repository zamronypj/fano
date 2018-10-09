{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}
unit FactoryImpl;

interface

uses
    DependencyIntf,
    DependencyContainerIntf,
    DependencyFactoryIntf;

type
    {------------------------------------------------
     base class for any class having capability to create
     other object

     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TFactory = class(TInterfacedObject, IDependencyFactory)
    protected
        dependencyContainer : IDependencyContainer;
    public
        constructor create(const dc : IDependencyContainer);
        destructor destroy(); override;
        function build() : IDependency; virtual; abstract;
    end;

implementation


    constructor TFactory.create(const dc : IDependencyContainer);
    begin
        dependencyContainer := dc;
    end;

    destructor TFactory.destroy();
    begin
        inherited destroy();
        dependencyContainer := nil;
    end;

end.

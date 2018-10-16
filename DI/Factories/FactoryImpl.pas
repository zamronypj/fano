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
    DependencyContainerIntf;

type
    {------------------------------------------------
     base class for any class having capability to create
     other object

     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TFactory = class(TInterfacedObject, IDependencyFactory)
    public
        function build(const container : IDependencyContainer) : IDependency; virtual; abstract;
    end;

implementation

end.

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
    DependencyFactoryIntf;

type
    {------------------------------------------------
     base class for any class having capability to create
     other object

     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TFactory = class(TInterfacedObject, IDependencyFactory)
    public
        function build() : IDependency; virtual; abstract;
        procedure cleanUp(); virtual;
    end;

implementation

    procedure TFactory.cleanUp();
    begin
        //intentionally do nothing
    end;

end.

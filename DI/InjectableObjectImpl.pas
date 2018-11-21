{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit InjectableObjectImpl;

interface

uses

    DependencyIntf;

type

    (*!-----------------------------------------------
     * Base class that can be injected into dependency container
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *------------------------------------------------*)
    TInjectableObject = class(TInterfacedObject, IDependency)
    end;

implementation

end.

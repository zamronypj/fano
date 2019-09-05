{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ServiceImpl;

interface

{$MODE OBJFPC}

uses

    ServiceIntf,
    InjectableObjectImpl;

type

    (*!-----------------------------------------------
     * Base class that can be injected into dependency container
     * which implements IService
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *------------------------------------------------*)
    TService = class(TInjectableObject, IService)
    end;

implementation

end.

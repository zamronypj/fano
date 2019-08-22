{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit ServiceFactoryIntf;

interface

{$MODE OBJFPC}

uses

    DependencyContainerIntf;

type
    {*!
     interface for any class that can be injected in
     depdendency container

     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    *}
    IServiceFactory = IDependencyFactory;

implementation
end.

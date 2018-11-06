{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}
unit DependencyListImpl;

interface

{$MODE OBJFPC}

uses

    DependencyListIntf,
    HashListImpl;

type
    {------------------------------------------------
     interface for any class having capability to
     store depdendency
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TDependencyList = class(THashList, IDependencyList)
    end;

implementation
end.

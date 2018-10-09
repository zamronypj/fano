{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}
unit DispatcherFactoryIntf;

interface

uses
    DependencyIntf,
    DependencyFactoryIntf;

type
    {------------------------------------------------
     interface for any class having capability
     to build dispatcher instance
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IDispatcherFactory = interface(IDependencyFactory)
        ['{13BA047B-BE9D-442C-A4BC-957A06BD291D}']
    end;

implementation
end.

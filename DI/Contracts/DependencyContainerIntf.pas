{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}
unit DependencyContainerIntf;

interface

uses
    DependencyIntf;

type
    {-----------------------------------
      make it forward declaration.
      We are forced to combine factory interface
      and container interface in one unit
      because of circular reference
    ------------------------------------}
    IDependencyFactory = interface;

    {------------------------------------------------
     interface for any class having capability to manage
     dependency

     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IDependencyContainer = interface
        ['{7B76FB8C-47E0-4EE2-9020-341867711D9A}']
        function add(const serviceName :string; const service : IDependencyFactory) : IDependencyContainer;
        function factory(const serviceName :string; const service : IDependencyFactory) : IDependencyContainer;
        function get(const serviceName : string) : IDependency;
    end;

    {------------------------------------------------
     interface for any class having capability to
     create other instance

     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IDependencyFactory = interface
        ['{BB858A2C-65DD-47C6-9A04-7C4CCA2816DD}']

        {*!----------------------------------------
         * build instance
         *------------------------------------------*}
        function build(const container : IDependencyContainer) : IDependency;
    end;

implementation
end.

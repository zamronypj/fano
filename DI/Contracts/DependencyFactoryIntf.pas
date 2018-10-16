{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}
unit DependencyFactoryIntf;

interface

uses
    DependencyIntf;

type
    {------------------------------------------------
     interface for any class
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IDependencyFactory = interface
        ['{BB858A2C-65DD-47C6-9A04-7C4CCA2816DD}']

        {*!----------------------------------------
         * build instance
         *------------------------------------------*}
        function build() : IDependency;

        {*!----------------------------------------
         * clean up factory data
         * ----------------------------------------
         * if factory hold reference to IDependencyContainer
         * instance, it will cause circular reference that
         * may cause memory leak because of reference-counted interface.
         * this method is provided so factory has opportunity
         * to release their hold to container instance to
         * avoid memory leak
         *------------------------------------------*}
        procedure cleanUp();
    end;

implementation
end.

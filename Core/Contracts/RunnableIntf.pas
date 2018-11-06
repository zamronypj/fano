{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}
unit RunnableIntf;

interface

{$MODE OBJFPC}

type
    {------------------------------------------------
     interface for any class that can be run
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IRunnable = interface
        ['{C5B758F0-D036-431C-9B69-E49B485FDC80}']
        function run() : IRunnable;
    end;

implementation

end.

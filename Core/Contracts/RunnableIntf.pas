unit RunnableIntf;

interface

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

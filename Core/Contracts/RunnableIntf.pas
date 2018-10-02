unit RunnableIntf;

interface

type
    {------------------------------------------------
     interface for any class that can be run
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IRunnable = interface
        function run() : IRunnable;
    end;

implementation
end.

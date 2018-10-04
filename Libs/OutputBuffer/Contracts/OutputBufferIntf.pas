unit OutputBufferIntf;

interface

type
    {------------------------------------------------
     interface for any class having capability to buffer
     standard output to a storage
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IOutputBuffer = interface
        ['{F84DF7E8-A03E-4244-89F2-0A88C196F41B}']

        {------------------------------------------------
         begin output buffering
        -----------------------------------------------}
        function beginBuffering() : IOutputBuffer;

        {------------------------------------------------
         end output buffering
        -----------------------------------------------}
        function endBuffering() : IOutputBuffer;

        {------------------------------------------------
         read output buffer content
        -----------------------------------------------}
        function read() : string;

        {------------------------------------------------
         read output buffer content and empty the buffer
        -----------------------------------------------}
        function flush() : string;
    end;

implementation
end.

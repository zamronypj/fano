{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}
unit OutputBufferExImpl;

interface
{$H+}
uses
    classes,
    DependencyIntf,
    OutputBufferIntf,
    OutputBufferStreamIntf;

type
    {------------------------------------------------
     class having capability to buffer
     standard output to a storage
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TOutputBufferEx = class(TInterfacedObject, IOutputBuffer, IDependency)
    private
        originalStdOutput, streamStdOutput: TextFile;
        stream : IOutputBufferStream;
        isBuffering : boolean;
    public
        constructor create(const aStream : IOutputBufferStream);
        destructor destroy(); override;

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

    constructor TOutputBufferEx.create(const aStream : IOutputBufferStream);
    begin
        stream := aStream;
        isBuffering := false;
    end;

    destructor TOutputBufferEx.destroy();
    begin
        inherited destroy();
        isBuffering := false;
        stream := nil;
    end;

    {------------------------------------------------
     begin output buffering
    -----------------------------------------------}
    function TOutputBufferEx.beginBuffering() : IOutputBuffer;
    begin
        if (not isBuffering) then
        begin
            isBuffering := true;
            stream.clear();
            stream.assignToFile(streamStdOutput);
            rewrite(streamStdOutput);
            //save original standard output, we can restore it
            originalStdOutput := Output;
            Output := streamStdOutput;
        end;
        result := self;
    end;

    {------------------------------------------------
     end output buffering
    -----------------------------------------------}
    function TOutputBufferEx.endBuffering() : IOutputBuffer;
    begin
        if (isBuffering) then
        begin
            isBuffering := false;
            //restore original standard output
            Output := originalStdOutput;
            stream.seek(0);
            closeFile(streamStdOutput);
        end;
        result := self;
    end;

    {------------------------------------------------
     read output buffer content
    -----------------------------------------------}
    function TOutputBufferEx.read() : string;
    begin
        result := stream.getContent();
    end;

    {------------------------------------------------
     read output buffer content and empty the buffer
    -----------------------------------------------}
    function TOutputBufferEx.flush() : string;
    begin
        result := stream.getContent();
        stream.clear();
    end;
end.

unit OutputBufferFactoryImpl;

interface

uses
    DependencyAwareIntf,
    DependencyContainerIntf,
    DependencyFactoryIntf,
    FactoryImpl;

type
    {------------------------------------------------
     factory class for TOutputBuffer

     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TOutputBufferFactory = class(TFactory, IDependencyFactory)
    public
        function build() : IDependencyAware; override;
    end;

implementation

uses
    OutputBufferImpl;

    function TOutputBufferFactory.build() : IDependencyAware;
    begin
        result := TOutputBuffer.create();
    end;

end.

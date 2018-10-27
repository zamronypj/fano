{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit FileLoggerFactoryImpl;

interface

{$MODE OBJFPC}

uses
    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl;

type
    {------------------------------------------------
     factory class for TFileLogger

     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TFileLoggerFactory = class(TFactory, IDependencyFactory)
    private
        logFile : string;
    public
        constructor create(const filename : string);
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses
    FileLoggerImpl;

    constructor TFileLoggerFactory.create(const filename : string);
    begin
        logFile := filename;
    end;

    function TFileLoggerFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TFileLogger.create(logFile);
    end;

end.

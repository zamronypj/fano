
{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit FastCGIAppImpl;

interface

{$MODE OBJFPC}
{$H+}


uses
    {$IFDEF unix}
    cthreads,
    {$ENDIF}
    Classes,
    SysUtils,
    Sockets,
    fpAsync,
    fpSock,

    RunnableIntf,
    DependencyContainerIntf,
    AppIntf,
    DispatcherIntf,
    EnvironmentIntf,
    ErrorHandlerIntf;

type

   (*!-----------------------------------------------
    * Worker thread instance that will handle
    *
    * @author Zamrony P. Juhara <zamronypj@yahoo.com>
    *-----------------------------------------------*)
    TWorkerThread = class(TThread)
    private
        FStream: TSocketStream;
    public
        constructor create(AClientStream: TSocketStream);
        procedure execute(); override;
    end;

implementation

end.

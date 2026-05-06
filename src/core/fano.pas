unit fano;

{$MODE OBJFPC}
{$H+}

{$IFNDEF CGI}
   {$DEFINE USE_DAEMON}
{$ENDIF}

interface

{$IFDEF USE_DAEMON}
   {$I fano_intf_daemon.inc}
{$ELSE}
   {$I fano_intf_non_daemon.inc}
{$ENDIF}

function fanoConfig() : TFanoConfig; overload;
function fanoConfig(const newCfg: TFanoConfig): TFanoConfig; overload;
function fanoCreate() : TFanoConfig;
function fanoRun(): longint;
function fanoFree(): longint;

implementation

{$IFDEF USE_DAEMON}
    {$I fano_impl_daemon.inc}
{$ELSE}
    {$I fano_impl_non_daemon.inc}
{$ENDIF}

end.

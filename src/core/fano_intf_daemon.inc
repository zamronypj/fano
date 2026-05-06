uses

   Classes,
   SysUtils,
   Sockets,
   {$IF DEFINED(LINUX)}
   BaseUnix,
   Unix,
   Linux
   {$ELSEIF DEFINED(BSD)}
   BaseUnix,
   Unix,
   Bsd
   {$ELSEIF DEFINED(WINDOWS)}
   Windows,
   Winsock2
   {$ELSE}
   BaseUnix,
   Unix
   {$ENDIF};

type

    TFanoConfig = record
      port: word;
      maxConn: integer;
      cleanIdleConnInterval: integer;
      threadPoolSize: integer;
      timeout: longint;
    end;



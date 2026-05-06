unit ServerTypes;

interface

uses
   Classes;

type

    TOpStatus = record
      wouldBlocked: boolean;
      error: boolean;
      errCode: longint;
      errMsg: string;
    end;

    // event called inside execute thread before run loop
    TOnBeforeRunLoop = procedure (callbackData: pointer; var userData: pointer);

    // event called inside execute thread after run loop
    TOnAfterRunLoop = procedure (callbackData: pointer; var userData: pointer);

    // event called when client connection is accepted.
    // connfd contains file descriptor of socket connection
    // userData is custom data to associate with connfd
    TOnAccepted = procedure (const connfd: longint; var userData: pointer);

    // event called when client connection is ready for I/O.
    // connfd contains file descriptor of socket connection
    // userData is custom data to associate with connfd set in onAccepted
    // isRead tells that connfd we should continue read
    // isWrite tells that connfd is for writing
    // isEnded tells that connfd is should be closed due peer closed connection
    // isError tells that connfd is should be closed due to error
    TOnDataAvail = procedure (
         const connfd: longint;
         var userData: pointer;
         var isRead: boolean;
         var isWrite : boolean;
         var isEnded : boolean;
         var isError: boolean);

    // event called when client connection is about to be closed.
    // connfd contains file descriptor of socket connection
    // userData is custom data to associate with connfd
    // this is provided so that caller has time to clean up userData
    TOnBeforeClose = procedure (const connfd: longint; var userData: pointer; var canClose: boolean);

    TArrThread = array of TThread;

implementation


end.

{-------------------------------------------------------------------------------
MIT License

Copyright (c) 2018 - Present Zamrony P. Juhara

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
-------------------------------------------------------------------------------}
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
    // maxRequestSize number of bytes allowed to read from client
    // userData is custom data to associate with connfd
    TOnAccepted = procedure (const connfd: longint;
         maxRequestSize, maxBodySize: integer;
         var userData: pointer);

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

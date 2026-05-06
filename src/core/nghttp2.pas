{
Modified version so that it can be compile on FPC 3.0.4

Original NgHttp2 header conversion License

DelphiScalableHttp is licensed under the Simplified BSD License.

-------------------------------------------------------------------------------

Copyright (c) 2017 by Grijjy, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
}
unit ngHttp2;


{ Header translation of ngHttp library for HTTP/2 protocol support, see https://nghttp2.org }

{x$I Grijjy.inc}

{ To build the library:
  Download the latest release from https://github.com/nghttp2/releases

For Windows...
  1.  Install CMAKE and the Build Tools for Visual Studio.
  2.  Run CMAKE followed by a period, (ex: cmake .)
  3.  Run CMAKE to build the release version (ex: cmake --build . --config RELEASE)

For Linux...
  1.  ./configure
  2.  sudo make
  3.  sudo make install
}

interface

const
  {$IF Defined(MSWINDOWS)}
  NGHTTP2_LIB = 'nghttp2.dll';
  {$ELSEIF Defined(LINUX)}
  NGHTTP2_LIB = 'libnghttp2.so';
  {$ENDIF}

const
  NGHTTP2_NO_ERROR = 0;

  NGHTTP2_ERR_CALLBACK_FAILURE = -902;

  NGHTTP2_DATA = 0;
  _NGHTTP2_HEADERS = 1;

  NGHTTP2_HCAT_REQUEST = 0;
  NGHTTP2_HCAT_RESPONSE = 1;

  NGHTTP2_NV_FLAG_NONE = 0;
  NGHTTP2_NV_FLAG_NO_INDEX = 1;
  NGHTTP2_NV_FLAG_NO_COPY_NAME = 2;
  NGHTTP2_NV_FLAG_NO_COPY_VALUE = 4;

  NGHTTP2_SETTINGS_MAX_CONCURRENT_STREAMS = 3;

  NGHTTP2_FLAG_NONE = 0;

  NGHTTP2_DATA_FLAG_NONE = 0;
  NGHTTP2_DATA_FLAG_EOF = 1;

type
  size_t = NativeUInt;
  ssize_t = NativeInt;
  puint8 = ^uint8;
  puint32 = ^uint32;

type
{ The primary structure to hold the resources needed for a HTTP/2
  session.  The details of this structure are intentionally hidden
  from the public API. }
  pnghttp2_session = Pointer;

{ Callback functions for :type:`nghttp2_session`.  The details of
  this structure are intentionally hidden from the public API. }
  pnghttp2_session_callbacks = Pointer;

{ The name/value pair, which mainly used to represent header fields. }
  nghttp2_nv = record
    name : MarshaledAString;
    value: MarshaledAString;
    namelen: size_t;
    valuelen: size_t;
    flags: uint8;
  end;
  pnghttp2_nv = ^nghttp2_nv;

{ The stream ID of the stream to depend on.  Specifying 0 makes stream
  not depend any other stream. }
  nghttp2_priority_spec = record
    stream_id: int32;
    weight: int32;
    exclusive: uint8;
  end;
  pnghttp2_priority_spec = ^nghttp2_priority_spec;

{ The SETTINGS ID/Value pair }
  nghttp2_settings_entry = record
    settings_id: int32;
    value: uint32;
  end;
  pnghttp2_settings_entry = ^nghttp2_settings_entry;

{ The frame header }
  nghttp2_frame_hd = record
    length: size_t;
    stream_id: int32;
    &type: uint8;
    flags: uint8;
    reserved: uint8;
  end;

{ The HEADERS frame }
  nghttp2_headers = record
    hd: nghttp2_frame_hd;
    padlen: size_t;
    pri_spec: nghttp2_priority_spec;
    nva: pnghttp2_nv;
    nvlen: size_t;
    cat: Integer; { enum }
  end;

{ This union includes all frames to pass them to various function
  calls as nghttp2_frame type. }
  nghttp2_frame = record
    case Integer of
    0:(hd: nghttp2_frame_hd);
    1:(headers: nghttp2_headers);
//    nghttp2_frame_hd hd;
//    nghttp2_data data;
//    nghttp2_headers headers;
//    nghttp2_priority priority;
//    nghttp2_rst_stream rst_stream;
//    nghttp2_settings settings;
//    nghttp2_push_promise push_promise;
//    nghttp2_ping ping;
//    nghttp2_goaway goaway;
//    nghttp2_window_update window_update;
//    nghttp2_extension ext;
  end;
  pnghttp2_frame = ^nghttp2_frame;

type
{ nghttp2_data_source_read_callback }

{ This union represents the some kind of data source passed to
  :type:`nghttp2_data_source_read_callback` }
  nghttp2_data_source = record
    case Integer of
    0:(fd: Integer);
    1:(ptr: Pointer);
  end;
  pnghttp2_data_source = ^nghttp2_data_source;

{ Callback function invoked when the library wants to read data from
  the |source|.  The read data is sent in the stream |stream_id|.
  The implementation of this function must read at most |length|
  bytes of data from |source| (or possibly other places) and store
  them in |buf| and return number of data stored in |buf|.  If EOF is
  reached, set :enum:`NGHTTP2_DATA_FLAG_EOF` flag in |*data_flags|. }
  nghttp2_data_source_read_callback = function(session: pnghttp2_session;
    stream_id: int32; buf: puint8; length: size_t;
    data_flags: puint32; source: pnghttp2_data_source; user_data: Pointer): ssize_t; cdecl;

{ This struct represents the data source and the way to read a chunk
  of data from it. }
  nghttp2_data_provider = record
    source: nghttp2_data_source;
    read_callback: nghttp2_data_source_read_callback;
  end;
  pnghttp2_data_provider = ^nghttp2_data_provider;

type
{ nghttp2_on_header_callback }

{ Callback function invoked when a header name/value pair is received
 for the |frame|.  The |name| of length |namelen| is header name.
 The |value| of length |valuelen| is header value.  The |flags| is
 bitwise OR of one or more of :type:`nghttp2_nv_flag`. }
  nghttp2_on_header_callback = function(session: pnghttp2_session; const frame: pnghttp2_frame;
    const name: puint8; namelen: size_t; const value: puint8; valuelen: size_t;
    flags: uint8; user_data: Pointer): Integer; cdecl;

type
{ nghttp2_on_frame_recv_callback }

{ Callback function invoked by `nghttp2_session_recv()` and
 `nghttp2_session_mem_recv()` when a frame is received.  The
 |user_data| pointer is the third argument passed in to the call to
 `nghttp2_session_client_new()` or `nghttp2_session_server_new()`. }
  nghttp2_on_frame_recv_callback = function(session: pnghttp2_session;
    const frame: pnghttp2_frame; user_data: Pointer): Integer; cdecl;

type
{ nghttp2_on_data_chunk_recv_callback }

{ Callback function invoked when a chunk of data in DATA frame is
  received.  The |stream_id| is the stream ID this DATA frame belongs to. }
  nghttp2_on_data_chunk_recv_callback = function(session: pnghttp2_session;
    flags: uint8; stream_id: int32; const data: puint8; len: size_t;
    user_data: Pointer): Integer; cdecl;

type
{ nghttp2_on_stream_close_callback }

{ Callback function invoked when the stream |stream_id| is closed.
  The reason of closure is indicated by the |error_code| }
  nghttp2_on_stream_close_callback = function(session: pnghttp2_session;
    stream_id: int32; error_code: uint32; user_data: Pointer): Integer; cdecl;

type
{ nghttp2_submit_settings_func }
  nghttp2_submit_settings_func = function(session: pnghttp2_session; flags: uint8;
      const iv: pnghttp2_settings_entry; niv: size_t): Integer; cdecl;

type
{ nghttp2_session_client_new_func }
  nghttp2_session_client_new_func = function(var session_ptr: pnghttp2_session;
    const callbacks: pnghttp2_session_callbacks; user_data: Pointer): Integer; cdecl;

  nghttp2_session_callbacks_new_func = function(out callbacks_ptr: pnghttp2_session_callbacks): Integer; cdecl;

  nghttp2_session_callbacks_del_func = procedure(callbacks: pnghttp2_session_callbacks); cdecl;

  nghttp2_session_callbacks_set_on_header_callback_func = procedure(callbacks: pnghttp2_session_callbacks;
    on_header_callback: nghttp2_on_header_callback); cdecl;

  nghttp2_session_callbacks_set_on_frame_recv_callback_func = procedure(callbacks: pnghttp2_session_callbacks;
    on_frame_recv_callback: nghttp2_on_frame_recv_callback); cdecl;

  nghttp2_session_callbacks_set_on_data_chunk_recv_callback_func = procedure(callbacks: pnghttp2_session_callbacks;
    on_data_chunk_recv_callback: nghttp2_on_data_chunk_recv_callback); cdecl;

  nghttp2_session_callbacks_set_on_stream_close_callback_func = procedure(callbacks: pnghttp2_session_callbacks;
    on_stream_close_callback: nghttp2_on_stream_close_callback); cdecl;

  nghttp2_session_terminate_session_func = function(session: pnghttp2_session; error_code: uint32): Integer; cdecl;

  nghttp2_submit_request_func = function(session: pnghttp2_session; const pri_spec: pnghttp2_priority_spec;
    const nva: pnghttp2_nv; nvlen: size_t; const data_prd: pnghttp2_data_provider; stream_user_data: Pointer): int32; cdecl;

  nghttp2_session_get_stream_user_data_func = function(session: pnghttp2_session;
    stream_id: int32): Pointer; cdecl;

  nghttp2_session_mem_recv_func = function(session: pnghttp2_session; const &in: Pointer; const inlen: size_t): Integer; cdecl;

  nghttp2_session_mem_send_func = function(session: pnghttp2_session; out data_ptr: Pointer): Integer; cdecl;

  nghttp2_session_want_read_func = function(session: pnghttp2_session): Integer; cdecl;

  nghttp2_session_want_write_func = function(session: pnghttp2_session): Integer; cdecl;

var
{ Stores local settings and submits SETTINGS frame.  The |iv| is the
  pointer to the array of :type:`nghttp2_settings_entry`.  The |niv|
  indicates the number of :type:`nghttp2_settings_entry`. }
  nghttp2_submit_settings: nghttp2_submit_settings_func = nil;

{ Initializes |*session_ptr| for client use.  The all members of |callbacks|
  are copied to |*session_ptr|.  Therefore |*session_ptr| does not store
  |callbacks|.  The |user_data| is an arbitrary user supplied data, which
  will be passed to the callback functions. }
  nghttp2_session_client_new: nghttp2_session_client_new_func = nil;

{ Initializes |*callbacks_ptr| with NULL values. }
  nghttp2_session_callbacks_new: nghttp2_session_callbacks_new_func = nil;

{ Frees any resources allocated for |callbacks|.  If |callbacks| is ``NULL``, this
  function does nothing. }
  nghttp2_session_callbacks_del: nghttp2_session_callbacks_del_func = nil;

{ Sets callback function invoked when a header name/value pair is received. }
  nghttp2_session_callbacks_set_on_header_callback: nghttp2_session_callbacks_set_on_header_callback_func = nil;

{ Sets callback function invoked by `nghttp2_session_recv()` and `nghttp2_session_mem_recv()`
  when a frame is received. }
  nghttp2_session_callbacks_set_on_frame_recv_callback: nghttp2_session_callbacks_set_on_frame_recv_callback_func = nil;

{ Sets callback function invoked when a chunk of data in DATA frame is received. }
  nghttp2_session_callbacks_set_on_data_chunk_recv_callback: nghttp2_session_callbacks_set_on_data_chunk_recv_callback_func = nil;

{ Sets callback function invoked when the stream is closed. }
  nghttp2_session_callbacks_set_on_stream_close_callback: nghttp2_session_callbacks_set_on_stream_close_callback_func = nil;

{ Signals the session so that the connection should be terminated. }
  nghttp2_session_terminate_session: nghttp2_session_terminate_session_func = nil;

{ Submits HEADERS frame and optionally one or more DATA frames. }
  nghttp2_submit_request: nghttp2_submit_request_func = nil;

{ Returns stream_user_data for the stream |stream_id|. }
  nghttp2_session_get_stream_user_data: nghttp2_session_get_stream_user_data_func = nil;

{ Processes data |in| as an input from the remote endpoint.  The
  |inlen| indicates the number of bytes in the |in|. }
  nghttp2_session_mem_recv: nghttp2_session_mem_recv_func = nil;

{ Returns the serialized data to send. }
  nghttp2_session_mem_send: nghttp2_session_mem_send_func = nil;

{ Returns nonzero value if |session| wants to receive data from the
  remote peer.  If both `nghttp2_session_want_read()` and `nghttp2_session_want_write()`
  return 0, the application should drop the connection. }
  nghttp2_session_want_read: nghttp2_session_want_read_func = nil;

{ Returns nonzero value if |session| wants to send data to the remote
  peer. If both `nghttp2_session_want_read()` and * `nghttp2_session_want_write()`
  return 0, the application should drop the connection. }
  nghttp2_session_want_write: nghttp2_session_want_write_func = nil;

//function MAKE_NV2(name, value: MarshaledAString): nghttp2_nv;
//function MAKE_NV(name, value: MarshaledAString; valuelen: uint8): nghttp2_nv;

implementation

uses
  Classes,
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF}
  SyncObjs,
  SysUtils;

var
  NGHTTP2Handle: HMODULE;

{ Helpers }

//function MAKE_NV2(name, value: MarshaledAString): nghttp2_nv;
//begin
//  Result.name := name;
//  Result.value := value;
//  Result.namelen := StrLen(name);
//  Result.valuelen := StrLen(value);
//  Result.flags := NGHTTP2_NV_FLAG_NONE;
//end;
//
//function MAKE_NV(name, value: MarshaledAString; valuelen: uint8): nghttp2_nv;
//begin
//  Result.name := name;
//  Result.value := value;
//  Result.namelen := StrLen(name);
//  Result.valuelen := valuelen;
//  Result.flags := NGHTTP2_NV_FLAG_NONE;
//end;

{ Library }

function LoadLib(const ALibFile: String): HMODULE;
begin
  Result := LoadLibrary(PChar(ALibFile));
  if (Result = 0) then
    raise Exception.CreateFmt('load %s failed', [ALibFile]);
end;

function FreeLib(ALibModule: HMODULE): Boolean;
begin
  Result := FreeLibrary(ALibModule);
end;

function GetProc(AModule: HMODULE; const AProcName: String): Pointer;
begin
  Result := GetProcAddress(AModule, PChar(AProcName));
  if (Result = nil) then
    raise Exception.CreateFmt('%s is not found', [AProcName]);
end;

procedure LoadNGHTTP2;
begin
  if (NGHTTP2Handle <> 0) then Exit;
  NGHTTP2Handle := LoadLib(NGHTTP2_LIB);
  if (NGHTTP2Handle = 0) then
  begin
    raise Exception.CreateFmt('Load %s failed', [NGHTTP2_LIB]);
    Exit;
  end;

  nghttp2_submit_settings := nghttp2_submit_settings_func(GetProc(NGHTTP2Handle, 'nghttp2_submit_settings'));

  nghttp2_session_client_new := nghttp2_session_client_new_func(GetProc(NGHTTP2Handle, 'nghttp2_session_client_new'));
  nghttp2_session_callbacks_new := nghttp2_session_callbacks_new_func(GetProc(NGHTTP2Handle, 'nghttp2_session_callbacks_new'));
  nghttp2_session_callbacks_del := nghttp2_session_callbacks_del_func(GetProc(NGHTTP2Handle, 'nghttp2_session_callbacks_del'));
  nghttp2_session_callbacks_set_on_header_callback := nghttp2_session_callbacks_set_on_header_callback_func(GetProc(NGHTTP2Handle, 'nghttp2_session_callbacks_set_on_header_callback'));
  nghttp2_session_callbacks_set_on_frame_recv_callback := nghttp2_session_callbacks_set_on_frame_recv_callback_func(GetProc(NGHTTP2Handle, 'nghttp2_session_callbacks_set_on_frame_recv_callback'));
  nghttp2_session_callbacks_set_on_data_chunk_recv_callback := nghttp2_session_callbacks_set_on_data_chunk_recv_callback_func(GetProc(NGHTTP2Handle, 'nghttp2_session_callbacks_set_on_data_chunk_recv_callback'));
  nghttp2_session_callbacks_set_on_stream_close_callback := nghttp2_session_callbacks_set_on_stream_close_callback_func(GetProc(NGHTTP2Handle, 'nghttp2_session_callbacks_set_on_stream_close_callback'));
  nghttp2_session_terminate_session := nghttp2_session_terminate_session_func(GetProc(NGHTTP2Handle, 'nghttp2_session_terminate_session'));

  nghttp2_submit_request := nghttp2_submit_request_func(GetProc(NGHTTP2Handle, 'nghttp2_submit_request'));
  nghttp2_session_get_stream_user_data := nghttp2_session_get_stream_user_data_func(GetProc(NGHTTP2Handle, 'nghttp2_session_get_stream_user_data'));

  nghttp2_session_mem_recv := nghttp2_session_mem_recv_func(GetProc(NGHTTP2Handle, 'nghttp2_session_mem_recv'));
  nghttp2_session_mem_send := nghttp2_session_mem_send_func(GetProc(NGHTTP2Handle, 'nghttp2_session_mem_send'));
  nghttp2_session_want_read := nghttp2_session_want_read_func(GetProc(NGHTTP2Handle, 'nghttp2_session_want_read'));
  nghttp2_session_want_write := nghttp2_session_want_write_func(GetProc(NGHTTP2Handle, 'nghttp2_session_want_write'));
end;

procedure UnloadNGHTTP2;
begin
  if (NGHTTP2Handle = 0) then Exit;
  FreeLib(NGHTTP2Handle);
  NGHTTP2Handle := 0;
end;

initialization
  LoadNGHTTP2;

finalization
  UnloadNGHTTP2;

end.

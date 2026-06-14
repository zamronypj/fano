
{---------------------------------------------------------------------------
MIT License

Copyright (c) 2021 - Present Zamrony P. Juhara

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
-----------------------------------------------------------------------------}
unit llhttp;

interface

uses

    ctypes,
    {$IFDEF UNIX}
    unixtype
    {$ENDIF};

{$LinkLib libllhttp.a}

const
    LLHTTP_VERSION_MAJOR = 9;
    LLHTTP_VERSION_MINOR = 4;
    LLHTTP_VERSION_PATCH = 1;


{$IFDEF FPC}
{$PACKRECORDS C}
{$ENDIF}


type

    llhttp__internal_s = record
        _index : longint;
        _span_pos0 : pointer;
        _span_cb0 : pointer;
        error : longint;
        reason : PAnsichar;
        error_pos : PAnsichar;
        data : pointer;
        _current : pointer;
        content_length : uint64;

        // actual name is type in llhttp.h, but because type is pascal keyword
        // we must use &type.
        &type : byte;

        method : byte;
        http_major : byte;
        http_minor : byte;
        header_state : byte;
        lenient_flags : word;
        upgrade : byte;
        finish : byte;
        flags : word;
        status_code : word;
        initial_message_completed : byte;
        settings : pointer;
    end;
    pllhttp__internal_s = ^llhttp__internal_s;

    llhttp__internal_t = llhttp__internal_s;
    pllhttp__internal_t  = ^llhttp__internal_t;


    llhttp_errno = (
      HPE_OK = 0,
      HPE_INTERNAL := 1,
      HPE_STRICT := 2,
      HPE_LF_EXPECTED := 3,
      HPE_UNEXPECTED_CONTENT_LENGTH := 4,
      HPE_CLOSED_CONNECTION := 5,
      HPE_INVALID_METHOD := 6,
      HPE_INVALID_URL := 7,
      HPE_INVALID_CONSTANT := 8,
      HPE_INVALID_VERSION := 9,
      HPE_INVALID_HEADER_TOKEN := 10,
      HPE_INVALID_CONTENT_LENGTH := 11,
      HPE_INVALID_CHUNK_SIZE := 12,
      HPE_INVALID_STATUS := 13,
      HPE_INVALID_EOF_STATE := 14,
      HPE_INVALID_TRANSFER_ENCODING := 15,
      HPE_CB_MESSAGE_BEGIN := 16,
      HPE_CB_HEADERS_COMPLETE := 17,
      HPE_CB_MESSAGE_COMPLETE := 18,
      HPE_CB_CHUNK_HEADER := 19,
      HPE_CB_CHUNK_COMPLETE := 20,
      HPE_PAUSED := 21,
      HPE_PAUSED_UPGRADE := 22,
      HPE_PAUSED_H2_UPGRADE := 23,
      HPE_USER := 24,
      HPE_CR_EXPECTED := 25,
      HPE_CB_URL_COMPLETE := 26,
      HPE_CB_STATUS_COMPLETE := 27,
      HPE_CB_HEADER_FIELD_COMPLETE := 28,
      HPE_CB_HEADER_VALUE_COMPLETE := 29,
      HPE_UNEXPECTED_SPACE := 30,
      HPE_CB_RESET := 31,
      HPE_CB_METHOD_COMPLETE := 32,
      HPE_CB_VERSION_COMPLETE := 33,
      HPE_CB_CHUNK_EXTENSION_NAME_COMPLETE := 34,
      HPE_CB_CHUNK_EXTENSION_VALUE_COMPLETE := 35,
      HPE_CB_PROTOCOL_COMPLETE := 38
    );
    pllhttp_errno  = ^llhttp_errno;

    llhttp_errno_t = llhttp_errno;
    pllhttp_errno_t = ^llhttp_errno_t;

    llhttp_flags = (
      F_CONNECTION_KEEP_ALIVE := $1,
      F_CONNECTION_CLOSE := $2,
      F_CONNECTION_UPGRADE := $4,
      F_CHUNKED := $8,
      F_UPGRADE := $10,
      F_CONTENT_LENGTH := $20,
      F_SKIPBODY := $40,
      F_TRAILING := $80,
      F_TRANSFER_ENCODING := $200
    );
    pllhttp_flags  = ^llhttp_flags;

    llhttp_flags_t = llhttp_flags;
    pllhttp_flags_t = ^llhttp_flags_t;

    llhttp_lenient_flags = (
      LENIENT_HEADERS := $1,
      LENIENT_CHUNKED_LENGTH := $2,
      LENIENT_KEEP_ALIVE := $4,
      LENIENT_TRANSFER_ENCODING := $8,
      LENIENT_VERSION := $10,
      LENIENT_DATA_AFTER_CLOSE := $20,
      LENIENT_OPTIONAL_LF_AFTER_CR := $40,
      LENIENT_OPTIONAL_CRLF_AFTER_CHUNK := $80,
      LENIENT_OPTIONAL_CR_BEFORE_LF := $100,
      LENIENT_SPACES_AFTER_CHUNK_SIZE := $200,
      LENIENT_HEADER_VALUE_RELAXED := $400
    );
    pllhttp_lenient_flags  = ^llhttp_lenient_flags;

    llhttp_lenient_flags_t = llhttp_lenient_flags;
    Pllhttp_lenient_flags_t = ^llhttp_lenient_flags_t;

    llhttp_type = (
      HTTP_BOTH := 0,
      HTTP_REQUEST := 1,
      HTTP_RESPONSE := 2
    );
    pllhttp_type  = ^llhttp_type;


    llhttp_type_t = llhttp_type;
    pllhttp_type_t = ^llhttp_type_t;

    // actual name type from lhttp.h is llhttp_finish but conflict with
    // llhttp_finish() function so we remove llhttp_finish and just use llhttp_finish_t
    llhttp_finish_t = (
      HTTP_FINISH_SAFE := 0,
      HTTP_FINISH_SAFE_WITH_CB := 1,
      HTTP_FINISH_UNSAFE := 2
    );
    pllhttp_finish_t = ^llhttp_finish_t;

    llhttp_method = (
      HTTP_DELETE := 0,
      HTTP_GET := 1,
      HTTP_HEAD := 2,
      HTTP_POST := 3,
      HTTP_PUT := 4,
      HTTP_CONNECT := 5,
      HTTP_OPTIONS := 6,
      HTTP_TRACE := 7,
      HTTP_COPY := 8,
      HTTP_LOCK := 9,
      HTTP_MKCOL := 10,
      HTTP_MOVE := 11,
      HTTP_PROPFIND := 12,
      HTTP_PROPPATCH := 13,
      HTTP_SEARCH := 14,
      HTTP_UNLOCK := 15,
      HTTP_BIND := 16,
      HTTP_REBIND := 17,
      HTTP_UNBIND := 18,
      HTTP_ACL := 19,
      HTTP_REPORT := 20,
      HTTP_MKACTIVITY := 21,
      HTTP_CHECKOUT := 22,
      HTTP_MERGE := 23,
      HTTP_MSEARCH := 24,
      HTTP_NOTIFY := 25,
      HTTP_SUBSCRIBE := 26,
      HTTP_UNSUBSCRIBE := 27,
      HTTP_PATCH := 28,
      HTTP_PURGE := 29,
      HTTP_MKCALENDAR := 30,
      HTTP_LINK := 31,
      HTTP_UNLINK := 32,
      HTTP_SOURCE := 33,
      HTTP_PRI := 34,
      HTTP_DESCRIBE := 35,
      HTTP_ANNOUNCE := 36,
      HTTP_SETUP := 37,
      HTTP_PLAY := 38,
      HTTP_PAUSE := 39,
      HTTP_TEARDOWN := 40,
      HTTP_GET_PARAMETER := 41,
      HTTP_SET_PARAMETER := 42,
      HTTP_REDIRECT := 43,
      HTTP_RECORD := 44,
      HTTP_FLUSH := 45,
      HTTP_QUERY := 46
    );
    pllhttp_method  = ^llhttp_method;


    llhttp_method_t = llhttp_method;
    pllhttp_method_t = ^llhttp_method_t;

    llhttp_status = (
      HTTP_STATUS_CONTINUE := 100,
      HTTP_STATUS_SWITCHING_PROTOCOLS := 101,
      HTTP_STATUS_PROCESSING := 102,
      HTTP_STATUS_EARLY_HINTS := 103,
      HTTP_STATUS_RESPONSE_IS_STALE := 110,
      HTTP_STATUS_REVALIDATION_FAILED := 111,
      HTTP_STATUS_DISCONNECTED_OPERATION := 112,
      HTTP_STATUS_HEURISTIC_EXPIRATION := 113,
      HTTP_STATUS_MISCELLANEOUS_WARNING := 199,
      HTTP_STATUS_OK := 200,
      HTTP_STATUS_CREATED := 201,
      HTTP_STATUS_ACCEPTED := 202,
      HTTP_STATUS_NON_AUTHORITATIVE_INFORMATION := 203,
      HTTP_STATUS_NO_CONTENT := 204,
      HTTP_STATUS_RESET_CONTENT := 205,
      HTTP_STATUS_PARTIAL_CONTENT := 206,
      HTTP_STATUS_MULTI_STATUS := 207,
      HTTP_STATUS_ALREADY_REPORTED := 208,
      HTTP_STATUS_TRANSFORMATION_APPLIED := 214,
      HTTP_STATUS_IM_USED := 226,
      HTTP_STATUS_MISCELLANEOUS_PERSISTENT_WARNING := 299,
      HTTP_STATUS_MULTIPLE_CHOICES := 300,
      HTTP_STATUS_MOVED_PERMANENTLY := 301,
      HTTP_STATUS_FOUND := 302,
      HTTP_STATUS_SEE_OTHER := 303,
      HTTP_STATUS_NOT_MODIFIED := 304,
      HTTP_STATUS_USE_PROXY := 305,
      HTTP_STATUS_SWITCH_PROXY := 306,
      HTTP_STATUS_TEMPORARY_REDIRECT := 307,
      HTTP_STATUS_PERMANENT_REDIRECT := 308,
      HTTP_STATUS_BAD_REQUEST := 400,
      HTTP_STATUS_UNAUTHORIZED := 401,
      HTTP_STATUS_PAYMENT_REQUIRED := 402,
      HTTP_STATUS_FORBIDDEN := 403,
      HTTP_STATUS_NOT_FOUND := 404,
      HTTP_STATUS_METHOD_NOT_ALLOWED := 405,
      HTTP_STATUS_NOT_ACCEPTABLE := 406,
      HTTP_STATUS_PROXY_AUTHENTICATION_REQUIRED := 407,
      HTTP_STATUS_REQUEST_TIMEOUT := 408,
      HTTP_STATUS_CONFLICT := 409,
      HTTP_STATUS_GONE := 410,
      HTTP_STATUS_LENGTH_REQUIRED := 411,
      HTTP_STATUS_PRECONDITION_FAILED := 412,
      HTTP_STATUS_PAYLOAD_TOO_LARGE := 413,
      HTTP_STATUS_URI_TOO_LONG := 414,
      HTTP_STATUS_UNSUPPORTED_MEDIA_TYPE := 415,
      HTTP_STATUS_RANGE_NOT_SATISFIABLE := 416,
      HTTP_STATUS_EXPECTATION_FAILED := 417,
      HTTP_STATUS_IM_A_TEAPOT := 418,
      HTTP_STATUS_PAGE_EXPIRED := 419,
      HTTP_STATUS_ENHANCE_YOUR_CALM := 420,
      HTTP_STATUS_MISDIRECTED_REQUEST := 421,
      HTTP_STATUS_UNPROCESSABLE_ENTITY := 422,
      HTTP_STATUS_LOCKED := 423,
      HTTP_STATUS_FAILED_DEPENDENCY := 424,
      HTTP_STATUS_TOO_EARLY := 425,
      HTTP_STATUS_UPGRADE_REQUIRED := 426,
      HTTP_STATUS_PRECONDITION_REQUIRED := 428,
      HTTP_STATUS_TOO_MANY_REQUESTS := 429,
      HTTP_STATUS_REQUEST_HEADER_FIELDS_TOO_LARGE_UNOFFICIAL := 430,
      HTTP_STATUS_REQUEST_HEADER_FIELDS_TOO_LARGE := 431,
      HTTP_STATUS_LOGIN_TIMEOUT := 440,
      HTTP_STATUS_NO_RESPONSE := 444,
      HTTP_STATUS_RETRY_WITH := 449,
      HTTP_STATUS_BLOCKED_BY_PARENTAL_CONTROL := 450,
      HTTP_STATUS_UNAVAILABLE_FOR_LEGAL_REASONS := 451,
      HTTP_STATUS_CLIENT_CLOSED_LOAD_BALANCED_REQUEST := 460,
      HTTP_STATUS_INVALID_X_FORWARDED_FOR := 463,
      HTTP_STATUS_REQUEST_HEADER_TOO_LARGE := 494,
      HTTP_STATUS_SSL_CERTIFICATE_ERROR := 495,
      HTTP_STATUS_SSL_CERTIFICATE_REQUIRED := 496,
      HTTP_STATUS_HTTP_REQUEST_SENT_TO_HTTPS_PORT := 497,
      HTTP_STATUS_INVALID_TOKEN := 498,
      HTTP_STATUS_CLIENT_CLOSED_REQUEST := 499,
      HTTP_STATUS_INTERNAL_SERVER_ERROR := 500,
      HTTP_STATUS_NOT_IMPLEMENTED := 501,
      HTTP_STATUS_BAD_GATEWAY := 502,
      HTTP_STATUS_SERVICE_UNAVAILABLE := 503,
      HTTP_STATUS_GATEWAY_TIMEOUT := 504,
      HTTP_STATUS_HTTP_VERSION_NOT_SUPPORTED := 505,
      HTTP_STATUS_VARIANT_ALSO_NEGOTIATES := 506,
      HTTP_STATUS_INSUFFICIENT_STORAGE := 507,
      HTTP_STATUS_LOOP_DETECTED := 508,
      HTTP_STATUS_BANDWIDTH_LIMIT_EXCEEDED := 509,
      HTTP_STATUS_NOT_EXTENDED := 510,
      HTTP_STATUS_NETWORK_AUTHENTICATION_REQUIRED := 511,
      HTTP_STATUS_WEB_SERVER_UNKNOWN_ERROR := 520,
      HTTP_STATUS_WEB_SERVER_IS_DOWN := 521,
      HTTP_STATUS_CONNECTION_TIMEOUT := 522,
      HTTP_STATUS_ORIGIN_IS_UNREACHABLE := 523,
      HTTP_STATUS_TIMEOUT_OCCURED := 524,
      HTTP_STATUS_SSL_HANDSHAKE_FAILED := 525,
      HTTP_STATUS_INVALID_SSL_CERTIFICATE := 526,
      HTTP_STATUS_RAILGUN_ERROR := 527,
      HTTP_STATUS_SITE_IS_OVERLOADED := 529,
      HTTP_STATUS_SITE_IS_FROZEN := 530,
      HTTP_STATUS_IDENTITY_PROVIDER_AUTHENTICATION_ERROR := 561,
      HTTP_STATUS_NETWORK_READ_TIMEOUT := 598,
      HTTP_STATUS_NETWORK_CONNECT_TIMEOUT := 599
    );
    pllhttp_status  = ^llhttp_status;

    llhttp_status_t = llhttp_status;
    pllhttp_status_t = ^llhttp_status_t;


    llhttp_t = llhttp__internal_t;
    pllhttp_t = ^llhttp_t;

    llhttp_data_cb = function (_para1: pllhttp_t; const at: PAnsichar; length: size_t) : longint; cdecl;

    llhttp_cb = function (_para1: pllhttp_t) : longint; cdecl;

  { Possible return values 0, -1, `HPE_PAUSED`  }
  { Possible return values 0, -1, HPE_USER  }
  { Possible return values:
     * 0  - Proceed normally
     * 1  - Assume that request/response has no body, and proceed to parsing the
     *      next message
     * 2  - Assume absence of body (as above) and make `llhttp_execute()` return
     *      `HPE_PAUSED_UPGRADE`
     * -1 - Error
     * `HPE_PAUSED`
      }
  { Possible return values 0, -1, HPE_USER  }
  { Possible return values 0, -1, `HPE_PAUSED`  }
  { When on_chunk_header is called, the current chunk length is stored
     * in parser->content_length.
     * Possible return values 0, -1, `HPE_PAUSED`
  }

    llhttp_settings_s = record
        on_message_begin : llhttp_cb;
        on_protocol : llhttp_data_cb;
        on_url : llhttp_data_cb;
        on_status : llhttp_data_cb;
        on_method : llhttp_data_cb;
        on_version : llhttp_data_cb;
        on_header_field : llhttp_data_cb;
        on_header_value : llhttp_data_cb;
        on_chunk_extension_name : llhttp_data_cb;
        on_chunk_extension_value : llhttp_data_cb;
        on_headers_complete : llhttp_cb;
        on_body : llhttp_data_cb;
        on_message_complete : llhttp_cb;
        on_protocol_complete : llhttp_cb;
        on_url_complete : llhttp_cb;
        on_status_complete : llhttp_cb;
        on_method_complete : llhttp_cb;
        on_version_complete : llhttp_cb;
        on_header_field_complete : llhttp_cb;
        on_header_value_complete : llhttp_cb;
        on_chunk_extension_name_complete : llhttp_cb;
        on_chunk_extension_value_complete : llhttp_cb;
        on_chunk_header : llhttp_cb;
        on_chunk_complete : llhttp_cb;
        on_reset : llhttp_cb;
    end;
    pllhttp_settings_s = ^llhttp_settings_s;

    llhttp_settings_t = llhttp_settings_s;
    pllhttp_settings_t = ^llhttp_settings_t;

  { Initialize the parser with specific type and user settings.
   *
   * NOTE: lifetime of `settings` has to be at least the same as the lifetime of
   * the `parser` here. In practice, `settings` has to be either a static
   * variable or be allocated with `malloc`, `new`, etc.
    }
procedure llhttp_init(parser: pllhttp_t;
    atype : llhttp_type_t;
    const settings : pllhttp_settings_t); cdecl; external;

function llhttp_alloc(atype: llhttp_type_t): pllhttp_t; cdecl; external;

procedure llhttp_free(parser: pllhttp_t); cdecl; external;

function llhttp_get_type(parser: pllhttp_t): byte; cdecl; external;

function llhttp_get_http_major(parser: pllhttp_t): byte; cdecl; external;

function llhttp_get_http_minor(parser: pllhttp_t): byte; cdecl; external;

function llhttp_get_method(parser: pllhttp_t): byte; cdecl; external;

function llhttp_get_status_code(parser: pllhttp_t): integer; cdecl; external;

function llhttp_get_upgrade(parser: pllhttp_t): byte; cdecl; external;

{ Reset an already initialized parser back to the start state, preserving the
  existing parser type, callback settings, user data, and lenient flags.
}
procedure llhttp_reset(parser: pllhttp_t); cdecl; external;

{ Initialize the settings object  }
procedure llhttp_settings_init(settings: pllhttp_settings_t); cdecl; external;

{ Parse full or partial request/response, invoking user callbacks along the
  * way.
  *
  * If any of `llhttp_data_cb` returns errno not equal to `HPE_OK` - the parsing
  * interrupts, and such errno is returned from `llhttp_execute()`. If
  * `HPE_PAUSED` was used as a errno, the execution can be resumed with
  * `llhttp_resume()` call.
  *
  * In a special case of CONNECT/Upgrade request/response `HPE_PAUSED_UPGRADE`
  * is returned after fully parsing the request/response. If the user wishes to
  * continue parsing, they need to invoke `llhttp_resume_after_upgrade()`.
  *
  * NOTE: if this function ever returns a non-pause type error, it will continue
  * to return the same error upon each successive call up until `llhttp_init()`
  * is called.
  }
function llhttp_execute(parser: pllhttp_t; const data: PAnsichar; len: Qword): llhttp_errno_t; cdecl; external;

{ This method should be called when the other side has no further bytes to
  * send (e.g. shutdown of readable side of the TCP connection.)
  *
  * Requests without `Content-Length` and other messages might require treating
  * all incoming bytes as the part of the body, up to the last byte of the
  * connection. This method will invoke `on_message_complete()` callback if the
  * request was terminated safely. Otherwise a error code would be returned.
  }
function llhttp_finish(parser: pllhttp_t): llhttp_errno_t; cdecl; external;

{ Returns `1` if the incoming message is parsed until the last byte, and has
  * to be completed by calling `llhttp_finish()` on EOF
}
function llhttp_message_needs_eof(const parser: pllhttp_t): integer; cdecl; external;

{ Returns `1` if there might be any other messages following the last that was
  successfully parsed.
}
function llhttp_should_keep_alive(const parser: pllhttp_t): integer; cdecl; external;


{ Make further calls of `llhttp_execute()` return `HPE_PAUSED` and set
  * appropriate error reason.
  *
  * Important: do not call this from user callbacks! User callbacks must return
  * `HPE_PAUSED` if pausing is required.
  }
procedure llhttp_pause(parser: pllhttp_t); cdecl; external;

{ Might be called to resume the execution after the pause in user's callback.
  * See `llhttp_execute()` above for details.
  *
  * Call this only if `llhttp_execute()` returns `HPE_PAUSED`.
  }
procedure llhttp_resume(parser: pllhttp_t); cdecl; external;

{ Might be called to resume the execution after the pause in user's callback.
  * See `llhttp_execute()` above for details.
  *
  * Call this only if `llhttp_execute()` returns `HPE_PAUSED_UPGRADE`
  }
procedure llhttp_resume_after_upgrade(parser: pllhttp_t); cdecl; external;

{ Returns the latest return error  }
function llhttp_get_errno(const parser: pllhttp_t): llhttp_errno_t; cdecl; external;

{ Returns the verbal explanation of the latest returned error.
  *
  * Note: User callback should set error reason when returning the error. See
  * `llhttp_set_error_reason()` for details.
  }
function llhttp_get_error_reason(const parser: pllhttp_t): pchar; cdecl; external;

{ Assign verbal description to the returned error. Must be called in user
  * callbacks right before returning the errno.
  *
  * Note: `HPE_USER` error code might be useful in user callbacks.
  }
procedure llhttp_set_error_reason(parser: pllhttp_t; const reason: pchar); cdecl; external;

{ Returns the pointer to the last parsed byte before the returned error. The
  * pointer is relative to the `data` argument of `llhttp_execute()`.
  *
  * Note: this method might be useful for counting the number of parsed bytes.
  }
function llhttp_get_error_pos(const parser: pllhttp_t): pchar; cdecl; external;

{ Returns textual name of error code  }
function llhttp_errno_name(err: llhttp_errno_t): pchar; cdecl; external;

{ Returns textual name of HTTP method  }
function llhttp_method_name(method: llhttp_method_t): pchar; cdecl; external;

{ Returns textual name of HTTP status  }
function llhttp_status_name(status: llhttp_status_t): pchar; cdecl; external;

{ Enables/disables lenient header value parsing (disabled by default).
  *
  * Lenient parsing disables header value token checks, extending llhttp's
  * protocol support to highly non-compliant clients/server. No
  * `HPE_INVALID_HEADER_TOKEN` will be raised for incorrect header values when
  * lenient parsing is "on".
  *
  * **Enabling this flag can pose a security issue since you will be exposed to
  * request smuggling attacks. USE WITH CAUTION!**
  }
procedure llhttp_set_lenient_headers(parser: pllhttp_t; enabled: integer); cdecl; external;

{ Enables/disables lenient handling of conflicting `Transfer-Encoding` and
  * `Content-Length` headers (disabled by default).
  *
  * Normally `llhttp` would error when `Transfer-Encoding` is present in
  * conjunction with `Content-Length`. This error is important to prevent HTTP
  * request smuggling, but may be less desirable for small number of cases
  * involving legacy servers.
  *
  * **Enabling this flag can pose a security issue since you will be exposed to
  * request smuggling attacks. USE WITH CAUTION!**
}
procedure llhttp_set_lenient_chunked_length(parser: pllhttp_t; enabled: integer); cdecl; external;

{ Enables/disables lenient handling of `Connection: close` and HTTP/1.0
  * requests responses.
  *
  * Normally `llhttp` would error on (in strict mode) or discard (in loose mode)
  * the HTTP request/response after the request/response with `Connection: close`
  * and `Content-Length`. This is important to prevent cache poisoning attacks,
  * but might interact badly with outdated and insecure clients. With this flag
  * the extra request/response will be parsed normally.
  *
  * **Enabling this flag can pose a security issue since you will be exposed to
  * poisoning attacks. USE WITH CAUTION!**
  }
procedure llhttp_set_lenient_keep_alive(parser: pllhttp_t; enabled: integer); cdecl; external;

{ Enables/disables lenient handling of `Transfer-Encoding` header.
  *
  * Normally `llhttp` would error when a `Transfer-Encoding` has `chunked` value
  * and another value after it (either in a single header or in multiple
  * headers whose value are internally joined using `, `).
  * This is mandated by the spec to reliably determine request body size and thus
  * avoid request smuggling.
  * With this flag the extra value will be parsed normally.
  *
  * **Enabling this flag can pose a security issue since you will be exposed to
  * request smuggling attacks. USE WITH CAUTION!**
}
procedure llhttp_set_lenient_transfer_encoding(parser: pllhttp_t; enabled: integer); cdecl; external;

{ Enables/disables lenient handling of HTTP version.
  *
  * Normally `llhttp` would error when the HTTP version in the request or status line
  * is not `0.9`, `1.0`, `1.1` or `2.0`.
  * With this flag the invalid value will be parsed normally.
  *
  * **Enabling this flag can pose a security issue since you will allow unsupported
  * HTTP versions. USE WITH CAUTION!**
  }
procedure llhttp_set_lenient_version(parser: pllhttp_t; enabled: integer); cdecl; external;

{ Enables/disables lenient handling of additional data received after a message ends
  * and keep-alive is disabled.
  *
  * Normally `llhttp` would error when additional unexpected data is received if the message
  * contains the `Connection` header with `close` value.
  * With this flag the extra data will discarded without throwing an error.
  *
  * **Enabling this flag can pose a security issue since you will be exposed to
  * poisoning attacks. USE WITH CAUTION!**
  }
procedure llhttp_set_lenient_data_after_close(parser: pllhttp_t; enabled: integer); cdecl; external;


{ Enables/disables lenient handling of incomplete CRLF sequences.
  *
  * Normally `llhttp` would error when a CR is not followed by LF when terminating the
  * request line, the status line, the headers or a chunk header.
  * With this flag only a CR is required to terminate such sections.
  *
  * **Enabling this flag can pose a security issue since you will be exposed to
  * request smuggling attacks. USE WITH CAUTION!**
  }
procedure llhttp_set_lenient_optional_lf_after_cr(parser: pllhttp_t; enabled: integer); cdecl; external;

{
  * Enables/disables lenient handling of line separators.
  *
  * Normally `llhttp` would error when a LF is not preceded by CR when terminating the
  * request line, the status line, the headers, a chunk header or a chunk data.
  * With this flag only a LF is required to terminate such sections.
  *
  * **Enabling this flag can pose a security issue since you will be exposed to
  * request smuggling attacks. USE WITH CAUTION!**
  }
procedure llhttp_set_lenient_optional_cr_before_lf(parser: pllhttp_t; enabled: integer); cdecl; external;

{ Enables/disables lenient handling of chunks not separated via CRLF.
  *
  * Normally `llhttp` would error when after a chunk data a CRLF is missing before
  * starting a new chunk.
  * With this flag the new chunk can start immediately after the previous one.
  *
  * **Enabling this flag can pose a security issue since you will be exposed to
  * request smuggling attacks. USE WITH CAUTION!**
  }
procedure llhttp_set_lenient_optional_crlf_after_chunk(parser: pllhttp_t; enabled: integer); cdecl; external;

{ Enables/disables lenient handling of spaces after chunk size.
  *
  * Normally `llhttp` would error when after a chunk size is followed by one or more
  * spaces are present instead of a CRLF or `;`.
  * With this flag this check is disabled.
  *
  * **Enabling this flag can pose a security issue since you will be exposed to
  * request smuggling attacks. USE WITH CAUTION!**
  }
procedure llhttp_set_lenient_spaces_after_chunk_size(parser: pllhttp_t; enabled: integer); cdecl; external;


{ Enables/disables relaxed handling of unusual characters in header values.
  *
  * RFC 9110 describes NULL, CR and LF as 'dangerous' and says they MUST be
  * rejected, while other control characters are merely 'invalid' and discouraged,
  * and are explicitly allowed by other standards (e.g. WHATWG Fetch) and
  * in surprisingly common use on the web.
  *
  * This flag enables these 'invalid but common' characters, aiming to
  * maximize compatibility without enabling any potentially dangerous scenarios.
  *
  * Unlike `llhttp_set_lenient_headers()`, this does NOT enable any other
  * potentially unsafe behaviors (like accepting whitespace before colons
  * or after the start line).
  }
procedure llhttp_set_lenient_header_value_relaxed(parser: pllhttp_t; enabled: integer); cdecl; external;

implementation

end.

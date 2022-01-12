unit libmicrohttpd_http2;

interface

{$IFDEF FPC}
    {$PACKRECORDS C}
{$ENDIF}

uses

    libnghttp2;

type

    h2_settings_entry = nghttp2_settings_entry;

    { Enables protocol HTTP/2.}
    MHD_USE_HTTP2 = 536870912;

    {*
     * HTTP/2 settings of the daemon, which are sent when a new client connection
     * occurs. This option should be followed by two arguments:
     *  - An integer of type `size_t`, which indicates the number of
     *    h2_settings_entry.
     *  - A pointer to a `h2_settings_entry` structure, an array of http2
     *    settings.
     * Note that the application must ensure that the buffer of the
     * second argument remains allocated and unmodified while the
     * deamon is running.
     * Settings parameters and their default values are defined in
     * https://tools.ietf.org/html/rfc7540#section-6.5.2
      }
    const MHD_OPTION_HTTP2_SETTINGS = 7540;

    { Clients can connect directly using HTTP/2. }
    const MHD_OPTION_HTTP2_DIRECT = 7541;

    { Clients can upgrade from HTTP/1.1 to HTTP/2. }
    const MHD_OPTION_HTTP2_UPGRADE = 7542;


implementation

end.

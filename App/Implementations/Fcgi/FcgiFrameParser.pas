{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit FcgiFrameParser;

interface

{$MODE OBJFPC}
{$H+}

type

    (*!-----------------------------------------------
     * FastCGI Frame Prser
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiFrameParser = class
    public
        function hasFrame(const buffer : string) : boolean;
        function parseFrame(const buffer : string) : IFcgiRecord;
    end;

implementation

uses

    fastcgi,
    EInvalidFcgiHeaderLenImpl;

    function TFcgiFrameParser.hasFrame(const buffer : string) : boolean;
    begin

    end;

    function TFcgiFrameParser.parseFrame(const buffer : string) : IFcgiRecord;
    begin
        if (length(buffer) < FCGI_HEADER_LEN) then
        begin
            raise EInvalidFcgiHeaderLen.create('Not enough data in the buffer to parse');
        end;
    end;

end.

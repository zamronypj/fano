{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2021 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit LnetCgiOutputImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    StreamAdapterIntf,
    lhttp,
    lwebserver;

type

    (*!-----------------------------------------------
     * Base class for handle write response to
     * LNet TLHTTPServer. This is provided to avoid
     * circular unit reference between LnetResponseAwareIntf
     * and LnetBufferedCgiOutputImpl units
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TLnetCgiOutput = class(TCGIOutput)
    protected
        fStreamAdapter : IStreamAdapter;
    public
        destructor destroy(); override;
        procedure writeResponse(const stream : IStreamAdapter); virtual;
    end;

implementation

    destructor TLnetCgiOutput.destroy();
    begin
        fStreamAdapter := nil;
        inherited destroy();
    end;


    procedure TLnetCgiOutput.writeResponse(const stream : IStreamAdapter);
    begin
        fStreamAdapter := stream;
        writeCGIBlock();
    end;

end.


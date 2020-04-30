{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit NotModifiedResponseImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    HeadersIntf,
    HttpCodeResponseImpl;

type
    (*!------------------------------------------------
     * 304 Not Modified Http response class
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TNotModifiedResponse = class(THttpCodeResponse)
    public
        constructor create(const hdrs : IHeaders);
    end;

implementation

    constructor TNotModifiedResponse.create(const hdrs : IHeaders);
    begin
        //create response with null body
        inherited create(304, 'Not Modified', hdrs.clone() as IHeaders);
        //remove headers that MUST NOT be included with 304 Not Modified responses
        headers.removeHeaders([
            'Allow',
            'Content-Encoding',
            'Content-Language',
            'Content-Length',
            'Content-Type',
            'Content-MD5',
            'Last-Modified'
        ]);
    end;

end.

{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FpcHttpHeadImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    HttpHeadClientIntf,
    ResponseStreamIntf,
    SerializeableIntf,
    FpcHttpMethodImpl;

type

    (*!------------------------------------------------
     * class that send HTTP HEAD to server
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFpcHttpHead = class(TFpcHttpMethod, IHttpHeadClient)
    public

        (*!------------------------------------------------
         * send HTTP HEAD request
         *-----------------------------------------------
         * @param url url to send request
         * @param data data related to this request
         * @return response from server
         *-----------------------------------------------*)
        function head(
            const url : string;
            const data : ISerializeable = nil
        ) : IResponseStream;

    end;

implementation

uses

    Classes,
    ResponseStreamImpl;

    (*!------------------------------------------------
     * send HTTP HEAD request
     *-----------------------------------------------
     * @param url url to send request
     * @param data data related to this request
     * @return current instance
     *-----------------------------------------------*)
    function TFpcHttpHead.head(
        const url : string;
        const data : ISerializeable = nil
    ) : IResponseStream;
    var stream : TStream;
    begin
        fullUrl := fQueryStrBuilder.buildUrlWithQueryParams(url, data);
        try
            stream := TMemoryStream.create();
            fpHttpClient.HTTPMethod('HEAD', url, stream, [200]);
            //wrap as IResponseStream and delete stream when goes out of scope
            result := TResponseStream.create(stream);
        except
            //something is wrong
            stream.free();
            result := nil;
        end;
    end;

end.

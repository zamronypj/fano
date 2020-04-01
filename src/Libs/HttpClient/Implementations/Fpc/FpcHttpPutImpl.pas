{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FpcHttpPutImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    HttpPutClientIntf,
    ResponseStreamIntf,
    SerializeableIntf,
    FpcHttpMethodImpl;

type

    (*!------------------------------------------------
     * class that send HTTP PUT to server
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFpcHttpPut = class(TFpcHttpMethod, IHttpPutClient)
    public

        (*!------------------------------------------------
         * send HTTP PUT request
         *-----------------------------------------------
         * @param url url to send request
         * @param data data related to this request
         * @return response from server
         *-----------------------------------------------*)
        function put(
            const url : string;
            const data : ISerializeable = nil
        ) : IResponseStream;

    end;

implementation

uses

    Classes,
    ResponseStreamImpl;

    (*!------------------------------------------------
     * send HTTP PUT request
     *-----------------------------------------------
     * @param url url to send request
     * @param data data related to this request
     * @return current instance
     *-----------------------------------------------*)
    function TFpcHttpPut.put(
        const url : string;
        const data : ISerializeable = nil
    ) : IResponseStream;
    var stream : TStream;
    begin
        fullUrl := fQueryStrBuilder.buildUrlWithQueryParams(url, data);
        try
            stream := TMemoryStream.create();
            fpHttpClient.put(url, stream);
            //wrap as IResponseStream and delete stream when goes out of scope
            result := TResponseStream.create(stream);
        except
            //something is wrong
            stream.free();
            result := nil;
        end;
    end;

end.

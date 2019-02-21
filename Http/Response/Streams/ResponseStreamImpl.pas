{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ResponseStreamImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    Classes,
    DependencyIntf,
    ResponseStreamIntf,
    StreamAdapterImpl;

type

    (*!----------------------------------------------
     * adapter class having capability as
     * HTTP response body
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TResponseStream = class(TStreamAdapter, IResponseStream, IDependency)
    public
        (*!------------------------------------
         * write string to stream
         *-------------------------------------
         * @param buffer string to write
         * @return number of bytes actually written
         *-------------------------------------*)
        function write(const buffer : string) : int64; overload;
    end;

implementation

    (*!------------------------------------
     * write string to stream
     *-------------------------------------
     * @param buffer string to write
     * @return number of bytes actually written
     *-------------------------------------*)
    function TResponseStream.write(const buffer : string) : int64;
    begin
        result := self.write(buffer[1], length(buffer));
    end;
end.

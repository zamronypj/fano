{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit MhdStdInReaderImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    StreamAdapterIntf,
    StdInIntf;

type

    (*!-----------------------------------------------
     * IStdIn implementation having capability to read
     * request body from libmicrohttpd
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TMhdStdInReader = class(TInjectableObject, IStdIn)
    public
        (*!------------------------------------------------
         * set stream to write to if any
         *-----------------------------------------------
         * @param stream, stream to write to
         * @return current instance
         *-----------------------------------------------*)
        function setStream(const astream : IStreamAdapter) : IStdIn;

        function readStdIn(const contentLength : int64) : string;
    end;

implementation

    function TMhdStdInReader.readStdIn(const contentLength : int64) : string;
    begin
    end;

    (*!------------------------------------------------
     * set stream to write to if any
     *-----------------------------------------------
     * @param stream, stream to write to
     * @return current instance
     *-----------------------------------------------*)
    function TMhdStdInReader.setStream(const astream : IStreamAdapter) : IStdIn;
    begin
        //intentionally does nothing
        result := self;
    end;
end.

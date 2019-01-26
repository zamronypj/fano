{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit StreamAdapterImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    StreamAdapterIntf;

type

    (*!------------------------------------------------
     * adapter class that implements IStreamAdapter
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TStreamAdapter = class(TInterfacedObject, IStreamAdapter)
    private
        actualStream : TStream;
    public
        (*!------------------------------------------------
         * constructor
         *-----------------------------------------------
         * @param stream instance of stream
         *-----------------------------------------------
         * Note: because we use reference counting,
         * stream will be owned by adapter, so when
         * adapter destroy() is called, the stream also
         * be destroyed
         *-----------------------------------------------*)
        constructor create(const stream : TStream);

        (*!------------------------------------------------
         * destructor
         *-----------------------------------------------
         * Note: because we use reference counting,
         * we need stream also be destroyed
         *-----------------------------------------------*)
        destructor destroy(); override;

        (*!------------------------------------------------
         * get stream size
         *-----------------------------------------------
         * @return stream size in bytes
         *-----------------------------------------------*)
        function size() : int64;

        (*!------------------------------------------------
         * read from stream to buffer
         *-----------------------------------------------
         * @param buffer, buffer to store data read
         * @param sizeToRead, total size in bytes to read
         * @return total bytes actually read
         *-----------------------------------------------*)
        function read(var buffer; const sizeToRead : int64) : int64;

        (*!------------------------------------------------
         * write from buffer to stream
         *-----------------------------------------------
         * @param buffer, buffer contains data to write
         * @param sizeToWrite, total size in bytes to write
         * @return total bytes actually written
         *-----------------------------------------------*)
        function write(const buffer; const sizeToWrite : int64) : int64;
    end;

implementation

uses

    EInvalidStreamImpl;

resourcestring

    SErrInvalidStream = 'Stream can not be nil';

    (*!------------------------------------------------
     * constructor
     *-----------------------------------------------
     * @param stream instance of stream
     *-----------------------------------------------
     * Note: because we use reference counting,
     * stream will be owned by adapter, so when
     * adapter destroy() is called, the stream also
     * be destroyed
     *-----------------------------------------------*)
    constructor TStreamAdapter.create(const stream : TStream);
    begin
        actualStream := stream;
        if (actualStream = nil) then
        begin
            raise EInvalidStream.create(SErrInvalidStream);
        end;
    end;

    (*!------------------------------------------------
     * destructor
     *-----------------------------------------------
     * Note: because we use reference counting,
     * we need stream also be destroyed
     *-----------------------------------------------*)
    destructor TStreamAdapter.destroy();
    begin
        inherited destroy();
        actualStream.free();
    end;


    (*!------------------------------------------------
     * get stream size
     *-----------------------------------------------
     * @return stream size in bytes
     *-----------------------------------------------*)
    function TStreamAdapter.size() : int64;
    begin
        result := actualStream.size;
    end;

    (*!------------------------------------------------
     * read from stream to buffer
     *-----------------------------------------------
     * @param buffer, buffer to store data read
     * @param sizeToRead, total size in bytes to read
     * @return total bytes actually read
     *-----------------------------------------------*)
    function TStreamAdapter.read(var buffer; const sizeToRead : int64) : int64;
    begin
        result := actualStream.read(buffer, sizeToRead);
    end;

    (*!------------------------------------------------
     * write from buffer to stream
     *-----------------------------------------------
     * @param buffer, buffer contains data to write
     * @param sizeToWrite, total size in bytes to write
     * @return total bytes actually written
     *-----------------------------------------------*)
    function TStreamAdapter.write(const buffer; const sizeToWrite : int64) : int64;
    begin
        result := actualStream.write(buffer, sizeToWrite);
    end;
end.

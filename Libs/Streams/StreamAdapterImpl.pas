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

    Classes,
    StreamAdapterIntf;

type

    (*!------------------------------------------------
     * adapter class that implements IStreamAdapter
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TStreamAdapter = class(TInterfacedObject, IStreamAdapter)
    private
        isOwned : boolean;
    protected
        actualStream : TStream;
    public
        (*!------------------------------------
         * constructor
         *-------------------------------------
         * @param stream instance of actual stream
         * @param owned true if streamInst is owned, meaning, its
         *        memory will be deallocated when destructor
         *        is called
         *-------------------------------------*)
        constructor create(const stream : TStream; const owned : boolean = true);

        (*!------------------------------------
         * destructor
         *-------------------------------------
         * if isOwned true, stream memory
         * will be deallocated when destructor
         * is called
         *-------------------------------------*)
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

        (*!------------------------------------------------
         * read from stream to buffer until all data is read
         *-----------------------------------------------
         * @param buffer, buffer to store data read
         * @param sizeToRead, total size in bytes to read
         *-----------------------------------------------*)
        procedure readBuffer(var buffer; const sizeToRead : int64);

        (*!------------------------------------------------
         * write from buffer to stream until all data is written
         *-----------------------------------------------
         * @param buffer, buffer contains data to write
         * @param sizeToWrite, total size in bytes to write
         *-----------------------------------------------*)
        procedure writeBuffer(const buffer; const sizeToWrite : int64);

        (*!------------------------------------------------
         * write from other stream
         *-----------------------------------------------
         * @param stream, stream contains data to write
         *-----------------------------------------------*)
        procedure writeStream(const stream : IStreamAdapter);

        (*!------------------------------------
         * seek
         *-------------------------------------
         * @param offset in bytes to seek start from beginning
         * @return actual offset
         *-------------------------------------
         * if offset >= stream size then it is capped
         * to stream size-1
         *-------------------------------------*)
        function seek(const offset : int64) : int64;

        (*!------------------------------------------------
         * reset stream
         *-----------------------------------------------
         * @return current instance
         *-----------------------------------------------*)
        function reset() : IStreamAdapter;
    end;

implementation

uses

    math,
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
    constructor TStreamAdapter.create(const stream : TStream; const owned : boolean = true);
    begin
        actualStream := stream;
        isOwned := owned;
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
        if (isOwned) then
        begin
            actualStream.free();
        end;
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

    (*!------------------------------------------------
     * read from stream to buffer until all data is read
     *-----------------------------------------------
     * @param buffer, buffer to store data read
     * @param sizeToRead, total size in bytes to read
     *-----------------------------------------------*)
    procedure TStreamAdapter.readBuffer(var buffer; const sizeToRead : int64);
    begin
        actualStream.readBuffer(buffer, sizeToRead);
    end;

    (*!------------------------------------------------
     * write from buffer to stream until all data is written
     *-----------------------------------------------
     * @param buffer, buffer contains data to write
     * @param sizeToWrite, total size in bytes to write
     *-----------------------------------------------*)
    procedure TStreamAdapter.writeBuffer(const buffer; const sizeToWrite : int64);
    begin
        actualStream.writeBuffer(buffer, sizeToWrite);
    end;

    (*!------------------------------------------------
     * write from other stream
     *-----------------------------------------------
     * @param stream, stream contains data to write
     *-----------------------------------------------*)
    procedure TStreamAdapter.writeStream(const stream : IStreamAdapter);
    const MAX_BUFF_SIZE = 4096;
    var buff : pointer;
        bytesToWrite, buffSize : int64;
    begin
        bytesToWrite := stream.size();
        if (bytesToWrite = 0) then
        begin
            exit();
        end;

        buffSize := min(MAX_BUFF_SIZE, bytesToWrite);

        getMem(buff, buffSize);
        try
            repeat
                stream.readBuffer(buff^, buffSize);
                writeBuffer(buff^, buffSize);
                buffSize := min(MAX_BUFF_SIZE, bytesToWrite - buffSize);
            until buffSize = 0;
        finally
            freeMem(buff);
        end;
    end;

    (*!------------------------------------
     * seek
     *-------------------------------------
     * @param offset in bytes to seek start from beginning
     * @return actual offset
     *-------------------------------------
     * if offset >= stream size then it is capped
     * to stream size-1
     *-------------------------------------*)
    function TStreamAdapter.seek(const offset : int64) : int64;
    begin
        result := actualStream.seek(offset, soFromBeginning);
    end;

    (*!------------------------------------------------
     * reset stream
     *-----------------------------------------------
     * @return current instance
     *-----------------------------------------------*)
    function TStreamAdapter.reset() : IStreamAdapter;
    begin
        actualStream.size := 0;
        result := self;
    end;
end.

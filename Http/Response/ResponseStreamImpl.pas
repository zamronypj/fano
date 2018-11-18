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
    ResponseStreamIntf;

type

    (*!----------------------------------------------
     * adapter class having capability as
     * HTTP response body
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TResponseStream = class(TInterfacedObject, IResponseStream, IDependency)
    private
        stream : TStream;
        isOwned : boolean;
    public
        (*!------------------------------------
         * constructor
         *-------------------------------------
         * @param streamInst instance of actual stream
         * @param owned true if streamInst is owned, meaning, its
         *        memory will be deallocated when destructor
         *        is called
         *-------------------------------------*)
        constructor create(const streamInst : TStream; const owned : boolean = true);

        (*!------------------------------------
         * destructor
         *-------------------------------------
         * if isOwned true, streamInst memory
         * will be deallocated when destructor
         * is called
         *-------------------------------------*)
        destructor destroy(); override;

        (*!------------------------------------
         * read stream to buffer from current
         * seek position
         *-------------------------------------
         * @param buffer pointer to buffer to store
         * @param sizeToRead number of bytes to read
         * @return number of bytes actually read
         *-------------------------------------
         * After read, implementation must advance its
         * internal pointer position to actual number
         * of bytes read
         *-------------------------------------*)
        function read(var buffer; const sizeToRead : longint) : longint;

        (*!------------------------------------
         * write buffer to stream
         *-------------------------------------
         * @param buffer pointer to buffer to write
         * @param sizeToWrite number of bytes to write
         * @return number of bytes actually written
         *-------------------------------------*)
        function write(const buffer; const sizeToWrite : longint) : longint;

        (*!------------------------------------
         * write string to stream
         *-------------------------------------
         * @param buffer string to write
         * @return number of bytes actually written
         *-------------------------------------*)
        function write(const buffer : string) : longint;

        (*!------------------------------------
         * get stream size
         *-------------------------------------
         * @return size of stream in bytes
         *-------------------------------------*)
        function size() : int64;

        (*!------------------------------------
         * seek
         *-------------------------------------
         * @param offset in bytes to seek start from beginning
         * @return actual offset
         *-------------------------------------
         * if offset >= stream size then it is capped
         * to stream size-1
         *-------------------------------------*)
        function seek(const offset : longint) : int64;
    end;

implementation

    (*!------------------------------------
     * constructor
     *-------------------------------------
     * @param streamInst instance of actual stream
     * @param owned true if streamInst is owned, meaning, its
     *        memory will be deallocated when destructor
     *        is called
     *-------------------------------------*)
    constructor TResponseStream.create(const streamInst : TStream; const owned : boolean = true);
    begin
        stream := streamInst;
        isOwned := owned;
    end;

    (*!------------------------------------
     * destructor
     *-------------------------------------
     * if isOwned true, streamInst memory
     * will be deallocated when destructor
     * is called
     *-------------------------------------*)
    destructor TResponseStream.destroy();
    begin
        inherited destroy();
        if (isOwned) then
        begin
            stream.free();
        end;
    end;

    (*!------------------------------------
     * read stream to buffer from current
     * seek position
     *-------------------------------------
     * @param buffer pointer to buffer to store
     * @param sizeToRead number of bytes to read
     * @return number of bytes actually read
     *-------------------------------------
     * After read, implementation must advance its
     * internal pointer position to actual number
     * of bytes read
     *-------------------------------------*)
    function TResponseStream.read(var buffer; const sizeToRead : longint) : longint;
    begin
        result := stream.read(buffer, sizeToRead);
    end;

    (*!------------------------------------
     * write buffer to stream
     *-------------------------------------
     * @param buffer pointer to buffer to write
     * @param sizeToWrite number of bytes to write
     * @return number of bytes actually written
     *-------------------------------------*)
    function TResponseStream.write(const buffer; const sizeToWrite : longint) : longint;
    begin
        result := stream.write(buffer, sizeToWrite);
    end;

    (*!------------------------------------
     * write string to stream
     *-------------------------------------
     * @param buffer string to write
     * @return number of bytes actually written
     *-------------------------------------*)
    function TResponseStream.write(const buffer : string) : longint;
    begin
        result := self.write(buffer[1], length(buffer));
    end;

    (*!------------------------------------
     * get stream size
     *-------------------------------------
     * @return size of stream in bytes
     *-------------------------------------*)
    function TResponseStream.size() : int64;
    begin
        result := stream.size;
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
    function TResponseStream.seek(const offset : longint) : int64;
    begin
        result := stream.seek(offset, soFromBeginning);
    end;
end.

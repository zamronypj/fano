{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit ResponseStreamIntf;

interface

{$MODE OBJFPC}
{$H+}

type

    (*!----------------------------------------------
     * interface for any class having capability as
     * HTTP response body
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IResponseStream = interface
        ['{14394487-875D-4C4E-B4AE-9176B7393CAC}']

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

end.

{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2021 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ReadOnlyFileResponseStreamImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    ResponseStreamIntf;

type

    (*!----------------------------------------------
     * response stream that load its data from file
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TReadOnlyReadOnlyFileResponseStream = class(TInterfacedObject, IResponseStream)
    private
        fFilename : string;
    public
        constructor create(const filename : string);

        (*!------------------------------------
         * write string to stream
         *-------------------------------------
         * @param buffer string to write
         * @return number of bytes actually written
         *-------------------------------------*)
        function write(const buffer : string) : int64; overload;

        (*!------------------------------------
         * read stream to string
         *-------------------------------------
         * @return string
         *-------------------------------------*)
        function read() : string; overload;
    end;

implementation

uses

    SysUtils,
    FileUtils,
    ENotFoundImpl;

resourcestring

    rsFileNotFound = 'File %s is not found.';

    constructor TReadOnlyFileResponseStream.create(const filename : string);
    begin
        fFilename := filename;
    end;

    (*!------------------------------------
     * write string to stream
     *-------------------------------------
     * @param buffer string to write
     * @return number of bytes actually written
     *-------------------------------------*)
    function TReadOnlyFileResponseStream.write(const buffer : string) : int64;
    begin
        //intentionally does nothing as we only care about read
        result := 0;
    end;

    (*!------------------------------------
     * read stream to string
     *-------------------------------------
     * @return string
     *-------------------------------------*)
    function TReadOnlyFileResponseStream.read() : string;
    begin
        try
            result := readFile(fFilename);
        except
            on e : EFOpenError do
            begin
                raise ENotFound.createFmt(rsFileNotFound, [fFilename]);
            end;
        end;
    end;

end.

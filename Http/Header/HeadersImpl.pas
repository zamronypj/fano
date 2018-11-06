{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit HeadersImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    DependencyIntf,
    CloneableIntf,
    HashListIntf,
    HeadersIntf;

type

    (*!------------------------------------------------
     * basic class having capability to
     * set and write HTTP headers
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    THeaders = class(TInterfacedObject, IHeaders, IDependency, ICloneable)
    private
        headerList : IHashList;
        procedure clearHeaders(const hdrList : IHashList);
    public
        constructor create(const hdrList : IHashList);
        destructor destroy(); override;

        (*!------------------------------------
         * set http header
         *-------------------------------------
         * @param key name  of http header to set
         * @param value value of header
         * @return header instance
         *-------------------------------------*)
        function setHeader(const key : shortstring; const value : string) : IHeaders;

        (*!------------------------------------
         * get http header
         *-------------------------------------
         * @param key name  of http header to get
         * @return header value
         * @throws EHeaderNotSet
         *-------------------------------------*)
        function getHeader(const key : shortstring) : string;

        (*!------------------------------------
         * test if http header already been set
         *-------------------------------------
         * @param key name  of http header to test
         * @return boolean true if header is set
         *-------------------------------------*)
        function has(const key : shortstring) : boolean;

        (*!------------------------------------
         * output http headers to STDIN
         *-------------------------------------
         * @return header instance
         *-------------------------------------*)
        function writeHeaders() : IHeaders;

        function clone() : ICloneable;
    end;

implementation

uses

    HashListImpl,
    EHeaderNotSetImpl;

resourcestring

    sErrHeaderNotSet = 'Header %s is not set';

type

    THeaderRec = record
        key : string;
        value : string;
    end;
    PHeaderRec = ^THeaderRec;

    constructor THeaders.create(const hdrList : IHashList);
    begin
        headerList := hdrList;
    end;

    destructor THeaders.destroy();
    begin
        inherited destroy();
        clearHeaders(headerList);
        headerList := nil;
    end;

    procedure THeaders.clearHeaders(const hdrList : IHashList);
    var i, len : integer;
        hdr : PHeaderRec;
    begin
        len := hdrList.count();
        for i := len-1 downto 0 do
        begin
            hdr := hdrList.get(i);
            setLength(hdr^.key, 0);
            setLength(hdr^.value, 0);
            dispose(hdr);
            hdrList.delete(i);
        end;
    end;

    (*!------------------------------------
     * set http header
     *-------------------------------------
     * @param key name  of http header to set
     * @param value value of header
     * @return header instance
     *-------------------------------------*)
    function THeaders.setHeader(const key : shortstring; const value : string) : IHeaders;
    var hdr : PHeaderRec;
    begin
        hdr := headerList.find(key);
        if (hdr = nil) then
        begin
            new(hdr);
            headerList.add(key, hdr);
        end;
        hdr^.key := key;
        hdr^.value := value;
        result := self;
    end;

    (*!------------------------------------
     * get http header
     *-------------------------------------
     * @param key name  of http header to get
     * @return header value
     * @throws EHeaderNotSet
     *-------------------------------------*)
    function THeaders.getHeader(const key : shortstring) : string;
    var hdr : PHeaderRec;
    begin
        hdr := headerList.find(key);
        if (hdr = nil) then
        begin
            raise EHeaderNotSet.createFmt(sErrHeaderNotSet, [key]);
        end;
        result := hdr^.value;
    end;

    (*!------------------------------------
     * test if http header already been set
     *-------------------------------------
     * @param key name  of http header to test
     * @return boolean true if header is set
     *-------------------------------------*)
    function THeaders.has(const key : shortstring) : boolean;
    begin
        result := (headerList.find(key) <> nil);
    end;

    (*!------------------------------------
     * output http headers to STDIN
     *-------------------------------------
     * @return header instance
     *-------------------------------------*)
    function THeaders.writeHeaders() : IHeaders;
    var i, len : integer;
        hdr : PHeaderRec;
    begin
        len := headerList.count();
        for i :=0 to len-1 do
        begin
            hdr := headerList.get(i);
            writeln(hdr^.key, ': ', hdr^.value);
        end;
        writeln();
        result := self;
    end;

    function THeaders.clone() : ICloneable;
    var i, len : integer;
        srcHdr, dstHdr : PHeaderRec;
        newHashList : IHashList;
    begin
        newHashList := THashList.create();
        len := headerList.count();
        for i :=0 to len-1 do
        begin
            srcHdr := headerList.get(i);
            new(dstHdr);
            dstHdr^.key := srcHdr^.key;
            dstHdr^.value := srcHdr^.value;
            newHashList.add(dstHdr^.key, dstHdr);
        end;
        result := THeaders.create(newHashList);
    end;

end.

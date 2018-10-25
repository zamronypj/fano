{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}

unit HeadersImpl;

interface

{$H+}

uses

    DependencyIntf,
    HashListIntf,
    HeadersIntf;

type

    (*!------------------------------------------------
     * basic class having capability to
     * set and write HTTP headers
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    THeaders = class(TInterfacedObject, IHeaders, IDependency)
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
         * output http headers to STDIN
         *-------------------------------------
         * @return header instance
         *-------------------------------------*)
        function writeHeaders() : IHeaders;

    end;

implementation

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
    function THeaders.setHeader(const key : shortstring; const value : string) : IHeadersInterface;
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
     * output http headers to STDIN
     *-------------------------------------
     * @return header instance
     *-------------------------------------*)
    function THeaders.writeHeaders() : IHeaders;
    var i, len : integer;
        hdr : PHeaderRec;
    begin
        len := hdrList.count();
        for i :=0 to len-1 do
        begin
            hdr := hdrList.get(i);
            writeln(hdr^.key, ':', hdr^.value);
        end;
        result := self;
    end;

end.

{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit HashListImpl;

interface

{$MODE OBJFPC}
{$H+}

uses
    contnrs,
    HashListIntf;

type
    {------------------------------------------------
     interface for any class having capability to store
     hash list
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    THashList = class(TInterfacedObject, IHashList)
    private
        hashes : TFPHashList;
    public
        constructor create();
        destructor destroy(); override;

        function count() : integer;
        function get(const indx : integer) : pointer;
        procedure delete(const indx : integer);
        function add(const key : shortstring; const data : pointer) : integer;
        function find(const key : shortstring) : pointer;
        function keyOfIndex(const indx : integer) : shortstring;
    end;

implementation

    constructor THashList.create();
    begin
        hashes := TFPHashList.create();
    end;

    destructor THashList.destroy();
    begin
        inherited destroy();
        hashes.free();
    end;

    function THashList.count() : integer;
    begin
        result := hashes.count;
    end;

    function THashList.get(const indx : integer) : pointer;
    begin
        result := hashes.items[indx];
    end;

    procedure THashList.delete(const indx : integer);
    begin
        hashes.delete(indx);
    end;

    function THashList.add(const key : shortstring; const data : pointer) : integer;
    begin
        result := hashes.add(key, data);
    end;

    function THashList.find(const key : shortstring) : pointer;
    begin
        result := hashes.find(key);
    end;

    function THashList.keyOfIndex(const indx : integer) : shortstring;
    begin
        result := hashes.nameOfIndex(indx);
    end;
end.

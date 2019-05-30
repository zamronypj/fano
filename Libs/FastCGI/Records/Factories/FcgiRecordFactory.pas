{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FcgiRecordFactory;

interface

{$MODE OBJFPC}
{$H+}

uses

    FcgiRecordIntf;

type

    (*!-----------------------------------------------
     * Base fastcgi record factory
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiRecordFactory = class
    protected
        tmpBuffer : pointer;
        tmpSize : int64;
    public
        constructor create(const buffer : pointer; const size : int64);

        (*!------------------------------------------------
        * build fastcgi record from stream
        *-----------------------------------------------
        * @param stream, stream instance where to write
        * @return number of bytes actually written
        *-----------------------------------------------*)
        function build() : IFcgiRecord; virtual; abstract;
    end;

implementation

    constructor TFcgiRecordFactory.create(const buffer : pointer; const size : int64);
    begin
        tmpBuffer := buffer;
        tmpSize := size;
    end;

end.

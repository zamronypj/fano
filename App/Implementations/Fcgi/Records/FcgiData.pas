{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit FcgiData;

interface

{$MODE OBJFPC}
{$H+}

uses

    FcgiStreamRecord;

type

    (*!-----------------------------------------------
     * data binary stream record (FCGI_DATA)
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiData = class(TFcgiStreamRecord)
    public
        constructor create(const requestId : word; const content : string = '');
    end;

implementation

uses

    fastcgi;

    constructor TFcgiData.create(const requestId : word; const content : string = '');
    begin
        inherited create(FCGI_DATA, requestId, content);
    end;

end.

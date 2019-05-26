{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
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

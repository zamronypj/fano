{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit FcgiParams;

interface

{$MODE OBJFPC}
{$H+}

type

    (*!-----------------------------------------------
     * Params record (FCGI_PARAMS)
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiParams = class(TFcgiRecord)
    private
        keyValues : IKeyValuePair;
    public
        constructor create(const aKeyValues : IKeyValuePair);
    end;

implementation

uses

    fastcgi;

    constructor TFcgiParams.create(const aKeyValues : IKeyValuePair);
    begin
        inherited create();
        fType := FCGI_PARAMS;
        keyValues := aKeyValues;
    end;
end.

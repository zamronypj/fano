{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit FcgiStdIn;

interface

{$MODE OBJFPC}
{$H+}

type

    (*!-----------------------------------------------
     * Standard input binary stream (FCGI_STDIN)
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiStdIn = class(TFcgiRecord)
    public
        constructor create(const content : string = '');
    end;

implementation

uses

    fastcgi;

    constructor TFcgiStdIn.create(const content : string = '');
    begin
        inherited create();
        fType := FCGI_STDIN;
        setContentData(content);
    end;
end.

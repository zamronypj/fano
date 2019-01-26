{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit FcgiRecord;

interface

uses

    fastcgi;

type

    TFcgiRecord = class(TInterfacedObject, IFcgiRecord)
    private
    protected
        fVersion : byte;
        fType : byte;

        //two bytes with big endian order
        fRequestId : word;
        fContentLength : word;

        fPaddingLength : byte;
        fReserved : byte;
    public
        constructor create();
        destructor destroy(); override;
    end;

implementation

end.

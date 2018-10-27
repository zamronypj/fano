{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit ResponseStreamIntf;

interface

{$MODE OBJFPC}
{$H+}

type

    (*!----------------------------------------------
     * interface for any class having capability as
     * HTTP response body
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IResponseStream = interface
        ['{14394487-875D-4C4E-B4AE-9176B7393CAC}']

        (*!------------------------------------
         * write buffer to stream
         *-------------------------------------
         * @param buffer pointer to buffer to write
         * @param sizeToWrite number of bytes to write
         * @return number of bytes actually written
         *-------------------------------------*)
        function write(const buffer; const sizeToWrite : longint) : longint;
    end;

implementation



end.
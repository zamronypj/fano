{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit DataAvailListenerIntf;

interface

{$MODE OBJFPC}
{$H+}

uses

    StreamAdapterIntf;

type

    (*!-----------------------------------------------
     * Interface for any class having capability to
     * handle data availability
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IDataAvailListener = interface
        ['{C8C08F35-663E-49ED-93CA-32E8345187E4}']

        (*!------------------------------------------------
        * test if buffer contain FastCGI frame package
        * i.e FastCGI header + payload
        *-----------------------------------------------
        * @param stream, stream that store data
        * @param context, additional data related to stream
        * @return true if data is handled
        *-----------------------------------------------*)
        function handleData(const stream : IStreamAdapter; const context : TObject) : boolean;

    end;

implementation

end.

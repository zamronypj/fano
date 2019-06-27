{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FcgiStdInStreamAwareIntf;

interface

{$MODE OBJFPC}
{$H+}

uses

    StreamAdapterIntf;

type

    (*!-----------------------------------------------
     * Interface for any class having capability return
     * StdIn stream

     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IFcgiStdInStreamAware = interface
        ['{C91FCF4D-0A9B-4EC3-A725-0C9808C6CBEF}']

        (*!------------------------------------------------
         * get StdIn stream
         *-----------------------------------------------
         * @return stdIn stream, stream contains parsed POST-ed data
         *-----------------------------------------------*)
        function getStdIn() : IStreamAdapter;

    end;

implementation

end.

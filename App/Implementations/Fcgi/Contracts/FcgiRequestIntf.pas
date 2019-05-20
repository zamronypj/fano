{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit FcgiRequestIntf;

interface

{$MODE OBJFPC}
{$H+}

type

    (*!-----------------------------------------------
     * Interface for any class having capability to hold
     * FastCGI request
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IFcgiRequest = interface
        ['{32C2BC0A-AF97-4EA0-A205-71F1FF05BFD5}']

        (*!------------------------------------------------
        * get current request id
        *-----------------------------------------------
        * @return id of current request
        *-----------------------------------------------*)
        function id() : word;
    end;

implementation

end.

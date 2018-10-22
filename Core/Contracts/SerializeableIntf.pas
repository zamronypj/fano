{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}
unit SerializeableIntf;

interface

{$H+}

type

    (*!------------------------------------------------
     * interface for any class having capability to
     * serialize its data
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    ISerializeable = interface
        ['{B83A84BF-8BCC-4796-87F2-A5F3810BE9CD}']
        function serialize() : string;
    end;

implementation



end.

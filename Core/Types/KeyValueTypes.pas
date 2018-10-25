{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}

unit KeyValueTypes;

interface

{$H+}

type

    (*!------------------------------------------------
     * Data type to store key value pair
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TKeyValue = record
        key : shortstring;
        value : string;
    end;
    PKeyValue = ^TKeyValue;

    TArrayOfKeyValue = array of TKeyValueParam;

implementation

end.
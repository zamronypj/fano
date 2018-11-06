{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit KeyValueTypes;

interface

{$MODE OBJFPC}
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

    TArrayOfKeyValue = array of TKeyValue;

implementation

end.
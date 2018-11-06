{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit PlaceholderTypes;

interface

{$MODE OBJFPC}
{$H+}

type

    (*!------------------------------------------------
     * Data structure for storing route variable placeholder
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     * -----------------------------------------------*)
    TPlaceholder = record
        phName : string;
        phValue : string;
        phFormatRegex : string;
    end;
    TArrayOfPlaceholders = array of TPlaceholder;


implementation

end.
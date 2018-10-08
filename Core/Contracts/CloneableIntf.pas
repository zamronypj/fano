{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}
unit CloneableIntf;

interface

type
    {*!
     interface for any class that can clone itself
     as new instance

     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    *}
    ICloneable = interface
        ['{ED9890E5-F8CA-4544-ADC7-495E6BB2650E}']
        function clone() : ICloneable;
    end;

implementation
end.

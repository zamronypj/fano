{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit UnserializeableIntf;

interface

{$MODE OBJFPC}
{$H+}

type

    (*!------------------------------------------------
     * interface for any class having capability to
     * create class instance from its serialized data
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IUnserializeable = interface
        ['{86A063FA-D673-41D7-85DE-0012403968C0}']
        function unserialize(const serializedData : string) : IInterface;
    end;

implementation

end.

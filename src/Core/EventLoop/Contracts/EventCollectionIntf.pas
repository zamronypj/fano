{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2022 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit EventCollectionIntf;

interface

{$MODE OBJFPC}

uses

    EventIntf;

type

    (*!-----------------------------------------------
     * interface for any class that for event collection
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IEventCollection = interface
        ['{650C59A0-FD02-4D74-BEF3-D84EB496AA74}']
        function get(const idx : integer) : IEvent;
        function count() : integer;
    end;

implementation

end.

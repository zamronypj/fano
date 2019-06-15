{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FcgiRecordManagerIntf;

interface

{$MODE OBJFPC}
{$H+}

uses

    FcgiRecordIntf;

type

    (*!-----------------------------------------------
     * Interface for any class having capability to combine
     * multiple FastCGI records and extract its data as
     * stream
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IFcgiRecordStream = interface
        ['{849142D5-8E36-46D3-8C63-C5DB6BF635AE}']

        (*!------------------------------------------------
        * add record
        *-----------------------------------------------
        * @return current instance
        *-----------------------------------------------*)
        function add(const rec : IFcgiRecord) : IFcgiRecordManager;

        (*!------------------------------------------------
        * read all records data and combine its data as
        * stream
        *-----------------------------------------------
        * @return stream of record data
        *-----------------------------------------------*)
        function data() : IStreamAdapter;

    end;

implementation

end.

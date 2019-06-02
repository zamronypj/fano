{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FcgiRequestManagerIntf;

interface

{$MODE OBJFPC}
{$H+}

uses

    FcgiRequestIntf;

type

    (*!-----------------------------------------------
     * Interface for any class having capability to manage
     * FastCGI requests multiplexing
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IFcgiRequestManager = interface
        ['{08E7C3A3-1E4D-4166-BA91-0BCFA03923C7}']

        (*!------------------------------------------------
        * test if request identified by id exist
        *-----------------------------------------------
        * @param id, request id to check
        * @return true if request identified by id exist
        *-----------------------------------------------*)
        function has(const id : word) : boolean;

        (*!------------------------------------------------
        * get request by id
        *-----------------------------------------------
        * @return request instance identified by id
        *-----------------------------------------------*)
        function get(const id : word) : IFcgiRequest;

        (*!------------------------------------------------
        * add request
        *-----------------------------------------------
        * @return id of current request
        *-----------------------------------------------*)
        function add(const req : IFcgiRequest) : IFcgiRequestManager;

        (*!------------------------------------------------
        * remove request
        *-----------------------------------------------
        * @return true of request is removed
        *-----------------------------------------------*)
        function remove(const id : word) : boolean;
    end;

implementation

end.

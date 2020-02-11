{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit AuthIntf;

interface

{$MODE OBJFPC}
{$H+}

uses

    RequestIntf,
    ResponseIntf,
    RouteArgsReaderIntf;

type

    (*!------------------------------------------------
     * interface for any class having capability to
     * handle Cross-Origin Resource Sharing request
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    IAuth = interface
        ['{548202A8-76B7-404C-AB3D-3E82C8EE3B94}']


        (*!------------------------------------------------
         * handle authentication
         *-------------------------------------------------
         * @param request current request object
         * @param response current response object
         * @param args route argument reader
         * @return boolean true if request is authenticated
         *-------------------------------------------------*)
        function auth(
            const request : IRequest;
            const response : IResponse;
            const args : IRouteArgsReader
        ) : boolean;

    end;

implementation

end.

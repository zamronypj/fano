{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit MiddlewareIntf;

interface

{$MODE OBJFPC}

uses

   RequestIntf,
   ResponseIntf;

type

    (*!------------------------------------------------
     * interface for any class having capability as middleware
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    IMiddleware = interface
        ['{E0ECB41C-8D8F-41C1-9FAC-7DFBD06ED8D4}']

        (*!---------------------------------------
         * handle request
         *----------------------------------------
         * @param request request instance
         * @param response response instance
         * @param canContinue return true if execution
         *        can continue to next middleware or false
         *        to stop execution
         * @return response
         *----------------------------------------*)
        function handleRequest(
            const request : IRequest;
            const response : IResponse;
            var canContinue : boolean
        ) : IResponse;
    end;

implementation
end.

{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit DispatcherIntf;

interface

{$MODE OBJFPC}

uses

    EnvironmentIntf,
    ResponseIntf;

type
    {------------------------------------------------
     interface for any class having capability dispatch
     request and return response
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IDispatcher = interface
        ['{F13A78C0-3A00-4E19-8C84-B6A7A77A3B25}']
        function dispatchRequest(const env: ICGIEnvironment) : IResponse;
    end;

implementation
end.

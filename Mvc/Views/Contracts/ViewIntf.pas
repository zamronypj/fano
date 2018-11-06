{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ViewIntf;

interface

{$MODE OBJFPC}

uses

    ResponseIntf,
    ViewParametersIntf;

type

    (*!------------------------------------------------
     * interface for any class having capability as view
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IView = interface(IResponse)
        ['{04F99A16-DDBC-403B-A099-8BB44BE3CCC5}']
        function render(
            const viewParams : IViewParameters;
            const response : IResponse
        ) : IResponse;
    end;

implementation

end.

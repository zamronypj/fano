{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit ResponseFactoryIntf;

interface

{$MODE OBJFPC}

uses

    EnvironmentIntf,
    ResponseIntf;

type
    (*!------------------------------------------------
     * interface for any class having capability
     * to build response instance
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *---------------------------------------------------*)
    IResponseFactory = interface
        ['{05A648AA-8AC1-4068-87F4-269D9A8D6C58}']
        function build(const env : ICGIEnvironment) : IResponse;
    end;

implementation

end.

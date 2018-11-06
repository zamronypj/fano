{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit BaseErrorHandlerImpl;

interface

{$MODE OBJFPC}
{$H+}

uses
    sysutils,
    DependencyIntf,
    ErrorHandlerIntf;

type

    (*!---------------------------------------------------
     * base custom error handler that user must inherit and
     * provide template to be displayed
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *---------------------------------------------------*)
    TBaseErrorHandler = class(TInterfacedObject, IErrorHandler, IDependency)
    public
        function handleError(
            const exc : Exception;
            const status : integer = 500;
            const msg : string  = 'Internal Server Error'
        ) : IErrorHandler; virtual; abstract;
    end;

implementation

end.

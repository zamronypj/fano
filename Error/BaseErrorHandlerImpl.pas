{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}

unit BaseErrorHandlerImpl;

interface

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

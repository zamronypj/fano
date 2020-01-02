{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ConditionalErrorHandlerImpl;

interface

{$MODE OBJFPC}
{$H+}

uses
    sysutils,
    ErrorHandlerIntf,
    EnvironmentEnumeratorIntf,
    CompositeErrorHandlerImpl;

type

    (*!---------------------------------------------------
     * error handler that is composed from two error handler
     * that is conditionally choosed based on some condition
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *---------------------------------------------------*)
    TConditionalErrorHandler = class (TCompositeErrorHandler)
    private
        fCondition : boolean;
    public
        (*!---------------------------------------------------
         * constructor
         *---------------------------------------------------
         * @param firstErrHandler first error handler
         * @param secondErrHandler second error handler
         * @param condition if true then use first handler otherwise
         *        use second handler
         *---------------------------------------------------*)
        constructor create(
            const firstErrHandler : IErrorHandler;
            const secondErrHandler : IErrorHandler;
            const condition : boolean;
        );

        function handleError(
            const env : ICGIEnvironmentEnumerator;
            const exc : Exception;
            const status : integer = 500;
            const msg : string  = 'Internal Server Error'
        ) : IErrorHandler; override;
    end;

implementation

    (*!---------------------------------------------------
     * constructor
     *---------------------------------------------------
     * @param firstErrHandler first error handler
     * @param secondErrHandler second error handler
     * @param condition if true then use first handler otherwise
     *        use second handler
     *---------------------------------------------------*)
    constructor TConditionalErrorHandler.create(
        const firstErrHandler : IErrorHandler;
        const secondErrHandler : IErrorHandler;
        const condition : boolean;
    );
    begin
        inherited create(firstErrHandler, secondErrHandler);
        fCondition := condition;
    end;

    function TConditionalErrorHandler.handleError(
        const env : ICGIEnvironmentEnumerator;
        const exc : Exception;
        const status : integer = 500;
        const msg : string  = 'Internal Server Error'
    ) : IErrorHandler;
    begin
        if fCondition then
        begin
            firstErrorHandler.handleError(env, exc, status, msg);
        end else
        begin
            secondErrorHandler.handleError(env, exc, status, msg);
        end;
        result := self;
    end;
end.

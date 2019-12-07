{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit VerbTunnellingDispatcherImpl;

interface

{$MODE OBJFPC}

uses

    EnvironmentIntf,
    StdInIntf,
    ResponseIntf,
    DispatcherIntf,
    InjectableObjectImpl;

type

    (*!---------------------------------------------------
     * descorator dispatcher that wrap environment to allow
     * HTTP verb to be override (verb tunneling).
     *
     * This class is provided so web application running behind
     * strict policy firewall which only allows GET and POST can
     * override its HTTP method using header X-Http-Method-Override
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *---------------------------------------------------*)
    TVerbTunnellingDispatcher = class(TInjectableObject, IDispatcher)
    private
        fActualDispatcher : IDipatcher;
    public
        constructor create(const actualDispatcher : IDispatcher);
        destructor destroy(); override;

        (*!-------------------------------------------
         * dispatch request
         *--------------------------------------------
         * @param env CGI environment
         * @param stdIn STDIN reader
         * @return response
         *--------------------------------------------*)
        function dispatchRequest(
            const env: ICGIEnvironment;
            const stdIn : IStdIn
        ) : IResponse;
    end;

implementation

uses

    EnvironmentEnumeratorIntf,
    VerbTunnellingEnvironmentImpl,
    NullEnvironmentImpl;

    constructor TVerbTunnellingDispatcher.create(const actualDispatcher : IDispatcher);
    begin
        fActualDispatcher := actualDispatcher;
    end;

    destructor TVerbTunnellingDispatcher.destroy();
    begin
        fActualDispatcher := nil;
        inherited destroy();
    end;

    (*!-------------------------------------------
     * dispatch request
     *--------------------------------------------
     * @param env CGI environment
     * @param stdIn STDIN reader
     * @return response
     *--------------------------------------------*)
    function TVerbTunnellingDispatcher.dispatchRequest(
        const env: ICGIEnvironment;
        const stdIn : IStdIn
    ) : IResponse;
    var envEnum : ICGIEnvironmentEnumerator;
    begin
        //check if it support environment enumeration
        if env is ICGIEnvironmentEnumerator then
        begin
            envEnum := env as ICGIEnvironmentEnumerator;
        end else
        begin
            //not support environment enumeration, so just pass null class
            envEnum := TNullCGIEnvironment.create();
        end;

        result := fActualDispatcher.dispatchRequest(
            TVerbTunnelingEnvironment.create(env, envEnum),
            stdIn
        );
    end;
end.

{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2020 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit Pbkdf2PasswordHashFactoryImpl;

interface

{$MODE OBJFPC}

uses

    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl,
    RequestHandlerIntf;

type

    (*!------------------------------------------------
     * factory class for TPbkdf2PasswordHash
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TPbkdf2PasswordHashFactory = class(TFactory, IDependencyFactory)
    public
        (*!---------------------------------------
         * build password hash instance
         *----------------------------------------
         * @param container dependency container
         * @return instance of middleware
         *----------------------------------------*)
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses

    Pbkdf2PasswordHashImpl;

    function TPbkdf2PasswordHashFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TPbkdf2PasswordHash.create();
    end;

end.

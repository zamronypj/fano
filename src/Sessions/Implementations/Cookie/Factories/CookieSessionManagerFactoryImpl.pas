{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit CookieSessionManagerFactoryImpl;

interface

{$MODE OBJFPC}

uses

    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl,
    SessionConsts,
    SessionFactoryIntf,
    EncrypterIntf,
    DecrypterIntf;

type
    (*!------------------------------------------------
     * TCookieSessionManager factory class
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TCookieSessionManagerFactory = class(TFactory)
    private
        fCookieName : string;
        fActualSessFactory : ISessionFactory;
        fEncrypter : IEncrypter;
        fDecrypter : IDecrypter;
    public
        constructor create(
            const cookieName : string = FANO_COOKIE_NAME;
            const actualSessFactory : ISessionFactory;
            const encrypter : IEncrypter;
            const decrypter : IDecrypter
        );

        destructor destroy(); override;

        (*!---------------------------------------------------
         * build class instance
         *----------------------------------------------------
         * @param container dependency container instance
         *----------------------------------------------------
         * This is implementation of IDependencyFactory
         *---------------------------------------------------*)
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses

    StringFileReaderImpl,
    CookieSessionManagerImpl,
    CookieSessionFactoryImpl,
    GuidSessionIdGeneratorImpl;

    constructor TCookieSessionManagerFactory.create(
        const cookieName : string = FANO_COOKIE_NAME;
        const actualSessFactory : ISessionFactory;
        const encrypter : IEncrypter;
        const decrypter : IDecrypter
    );
    begin
        fCookieName := cookieName;
        fActualSessFactory := actualSessFactory;
        fEncrypter := encrypter;
        fDecrypter := decrypter;
    end;

    destructor TCookieSessionManagerFactory.destroy();
    begin
        fActualSessFactory := nil;
        fEncrypter := nil;
        fDecrypter := nil;
        inherited destroy();
    end;

    (*!---------------------------------------------------
     * build class instance
     *----------------------------------------------------
     * @param container dependency container instance
     *---------------------------------------------------*)
    function TCookieSessionManagerFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TCookieSessionManager.create(
            TGuidSessionIdGenerator.create(),
            TCookieSessionFactory.create(fActualSessionFactory, fEncrypter),
            fCookieName,
            fDecrypter
        );
    end;
end.

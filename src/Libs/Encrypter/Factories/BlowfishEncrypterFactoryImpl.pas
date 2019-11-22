{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit BlowfishEncrypterFactoryImpl;

interface

{$MODE OBJFPC}

uses

    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl;

type
    (*!------------------------------------------------
     * TBlowfishEncrypter factory class
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TBlowfishEncrypterFactory = class(TFactory)
    private
        fSecretKey : string;
    public
        function secretKey(const key : string) : TBlowfishEncrypterFactory;

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

    BlowfishEncrypterImpl;

    function TBlowfishEncrypterFactory.secretKey(const key : string) : TBlowfishEncrypterFactory;
    begin
        fSecretKey := key;
        result := self;
    end;

    (*!---------------------------------------------------
     * build class instance
     *----------------------------------------------------
     * @param container dependency container instance
     *---------------------------------------------------*)
    function TBlowfishEncrypterFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TBlowfishEncrypter.create(fSecretKey);
    end;
end.

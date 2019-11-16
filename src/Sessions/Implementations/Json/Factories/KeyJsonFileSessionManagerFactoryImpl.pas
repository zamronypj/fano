{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit KeyJsonFileSessionManagerFactoryImpl;

interface

{$MODE OBJFPC}

uses

    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl,
    SessionConsts;

type
    (*!------------------------------------------------
     * TJsonFileSessionManager factory class which uses
     * secret key to HMAC SHA1 to generate session id
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TKeyJsonFileSessionManagerFactory = class(TJsonFileSessionManagerFactory)
    private
        fSecretKey : string;
    protected
        function getIdGenerator() : ISessionIdGenerator; override;
    public
        function secretKey(const key : string) : TKeyJsonFileSessionManagerFactory;
    end;

implementation

uses

    KeySessionIdGeneratorImpl,
    GuidSessionIdGeneratorImpl,
    Sha1SessionIdGeneratorImpl;

    function TKeyJsonFileSessionManagerFactory.secretKey(const key : string) : TKeyJsonFileSessionManagerFactory;
    begin
        fSecretKey := key;
        result := self;
    end;

    function TKeyJsonFileSessionManagerFactory.getIdGenerator() : ISessionIdGenerator;
    begin
        result := TSha1SessionIdGenerator.create(
            TKeySessionIdGenerator.create(
                TGuidSessionIdGenerator.create(),
                fSecretKey
            )
        );
    end;
end.

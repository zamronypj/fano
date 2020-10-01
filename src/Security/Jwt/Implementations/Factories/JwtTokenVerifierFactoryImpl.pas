{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2020 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit JwtTokenFactoryImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl,
    ListIntf,
    JwtAlgVerifierIntf;

type

    (*!------------------------------------------------
     * factory class for TJwtToken
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TJwtTokenVerifierFactory = class(TFactory, IDependencyFactory)
    private
        fSecret : string;
        fIssuer : string;
        fMetadataList : IList;
        fAlgorithms : array of IJwtAlgVerifier;
    public
        constructor create();

        function secret(const asecret : string) : TJwtTokenVerifierFactory;
        function issuer(const aissuer : string) : TJwtTokenVerifierFactory;
        function metadata(const ametadata : IList) : TJwtTokenVerifierFactory;
        function algorithms(const algos : array of IJwtAlgVerifier) : TJwtTokenVerifierFactory;

        (*!---------------------------------------
         * build JWT token verifier instance
         *----------------------------------------
         * @param container dependency container
         * @return instance of middleware
         *----------------------------------------*)
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses

    HashListImpl,
    JwtTokenVerifierImpl,
    NoneJwtAlgImpl,
    HmacSha256JwtAlgImpl,
    HmacSha384JwtAlgImpl,
    HmacSha512JwtAlgImpl;

const

    DEFAULT_ISSUER = 'fano';

    constructor TJwtTokenVerifierFactory.create();
    begin
        fIssuer := DEFAULT_ISSUER;
        fMetadataList := THashList.create();
        fAlgorithms := [
            THmacSha256JwtAlg.create(),
            TNoneJwtAlg.create(),
            THmacSha384JwtAlg.create(),
            THmacSha512JwtAlg.create()
        ];
    end;

    function TJwtTokenVerifierFactory.secret(const asecret : string) : TJwtTokenVerifierFactory;
    begin
        fSecret := asecret;
        result := self;
    end;

    function TJwtTokenVerifierFactory.issuer(const aissuer : string) : TJwtTokenVerifierFactory;
    begin
        fIssuer := aissuer;
        result := self;
    end;

    function TJwtTokenVerifierFactory.metadata(const ametadata : IList) : TJwtTokenVerifierFactory;
    begin
        fMetadataList := ametadata;
        result := self;
    end;

    function TJwtTokenVerifierFactory.algorithms(const algos : array of IJwtAlgVerifier) : TJwtTokenVerifierFactory;
    begin
        fAlgorithms := algos;
        result := self;
    end;

    function TJwtTokenVerifierFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TJwtTokenVerifier.create(
            fMetadataList,
            fIssuer,
            fSecret,
            fAlgorithms
        );
    end;

end.

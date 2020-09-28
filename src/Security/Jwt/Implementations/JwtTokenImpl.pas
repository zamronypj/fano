{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2020 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit JwtTokenImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    ListIntf,
    TokenVerifierIntf,
    JwtAlgIntf,
    InjectableObjectImpl;

type

    TAlg = record
        alg : shortString;
        inst : IJwtAlg;
    end;
    PAlg = ^TAlg;

    (*!------------------------------------------------
     * class having capability to verify JWT token validity
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TJwtToken = class (TInjectableObject, ITokenVerifier)
    private
        fSecretKey : string;
        fAlgorithms : IList;
        procedure cleanUpAlgo();
    public
        constructor create(
            const secretKey : string;
            const algos: array of TAlg
        );
        destructor destroy(); override;

        (*!------------------------------------------------
         * verify token
         *-------------------------------------------------
         * @param token token to verify
         * @return boolean true if token is verified
         *-------------------------------------------------*)
        function verify(const token : string) : boolean;

    end;

implementation

uses

    fpjwt,
    EJwtImpl,
    HashListImpl;

    constructor TJwtToken.create(
        const secretKey : string;
        const algos: array of TAlg
    );
    var i : integer;
        alg : PAlg;
    begin
        fSecretKey := secretKey;
        fAlgorithms := THashList.create();
        for i := low(algos) to high(algos) do
        begin
            new(alg);
            alg^.alg := algos[i].alg;
            alg^.inst := algos[i].inst;
            fAlgorithms.add(alg^.alg, alg);
        end;
    end;

    destructor TJwtToken.destroy();
    begin
        cleanUpAlgo();
        fAlgorithms := nil;
        inherited destroy();
    end;

    procedure TJwtToken.cleanUpAlgo();
    var i : integer;
        alg : PAlg;
    begin
        for i := fAlgorithms.count-1 downto 0 do
        begin
            alg := fAlgorithms.get(i);
            alg^.inst := nil;
            dispose(alg);
            fAlgorithms.delete(i);
        end;
    end;

    (*!------------------------------------------------
     * verify token
     *-------------------------------------------------
     * @param token token to verify
     * @return boolean true if token is verified
     *-------------------------------------------------*)
    function TJwtToken.verify(const token : string) : boolean;
    var jwt : TJwt;
        alg : IJwtAlg;
    begin
        jwt := TJwt.create();
        try
            jwt.asEncodedString := token;
            if fAlgorithms.has(jwt.JOSE.alg) then
            begin
                alg := fAlgorithms[jwt.JOSE.alg];
                result := alg.verify(token, fSecretKey);
            end else
            begin
                raise EJwt.createFmt('Unknown JWT algorithm %s', [jwt.JOSE.alg]);
            end;
        finally
            jwt.free();
        end;
    end;

end.

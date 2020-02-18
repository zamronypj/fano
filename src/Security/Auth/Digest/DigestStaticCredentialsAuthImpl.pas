{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit DigestStaticCredentialsAuthImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    RequestIntf,
    ResponseIntf,
    RouteArgsReaderIntf,
    AuthIntf,
    CredentialTypes,
    DigestInfoTypes;

type

    (*!------------------------------------------------
     * basic class having capability to authenticate user
     * using simple array of allowed credentials
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TDigestStaticCredentialsAuth = class (TInterfacedObject, IAuth)
    private
        fAllowedCredentials : TCredentials;

        function calcDigestResponse(
            const authCredDigest : PDigestInfo;
            const allowedCred : TCredential
        ) : string;

        (*!------------------------------------------------
         * test if a credential is in allowed credentials list
         *-------------------------------------------------
         * @param authCred credential to check
         * @param allowedCred array of allowed credentials
         * @return boolean true if credential is in allowed credentials
         *-------------------------------------------------*)
        function isAllowedCredential(
            const authCred : TCredential;
            const allowedCred : TCredentials
        ) : boolean;
    public
        (*!------------------------------------------------
         * constructor
         *-------------------------------------------------
         * @param allowedCred array of allowed credentials
         *-------------------------------------------------*)
        constructor create(const allowedCred : TCredentials);

        (*!------------------------------------------------
         * destructor
         *-------------------------------------------------*)
        destructor destroy(); override;

        (*!------------------------------------------------
         * authenticate credential
         *-------------------------------------------------
         * @param credential credential to authenticate
         * @return boolean true if credential is authenticated
         *-------------------------------------------------*)
        function auth(const credential : TCredential) : boolean;

    end;

implementation

uses

    md5;

    (*!------------------------------------------------
     * constructor
     *-------------------------------------------------
     * @param allowedCred array of allowed credentials
     *-------------------------------------------------*)
    constructor TDigestStaticCredentialsAuth.create(const allowedCred : TCredentials);
    begin
        fAllowedCredentials := allowedCred;
    end;

    (*!------------------------------------------------
     * destructor
     *-------------------------------------------------*)
    destructor TDigestStaticCredentialsAuth.destroy();
    begin
        fAllowedCredentials := nil;
        inherited destroy();
    end;

    function TDigestStaticCredentialsAuth.calcDigestResponse(
        const authCredDigest : PDigestInfo;
        const allowedCred : TCredential
    ) : string;
    var
        ha1, ha2, origResponse : string;
    begin
        ha1 := MD5Print(
            MD5String(
                allowedCred.username + ':' +
                authCredDigest^.realm + ':' +
                allowedCred.password
            )
        );

        ha2 := MD5Print(
            MD5String(authCredDigest^.method + ':' + authCredDigest^.uri)
        );

        if authCredDigest^.qop = '' then
        begin
            origResponse := ha1 + ':' + authCredDigest^.nonce + ':' + ha2;
        end else
        begin
            origResponse := ha1 + ':' +
                authCredDigest^.nonce + ':' +
                authCredDigest^.nc + ':' +
                authCredDigest^.cnonce + ':' +
                authCredDigest^.qop + ':' +
                ha2;
        end;

        result := MD5Print(MD5String(origResponse));
    end;

    (*!------------------------------------------------
     * test if a credential is in allowed credentials list
     *-------------------------------------------------
     * @param authCred credential to check
     * @param allowedCred array of allowed credentials
     * @return boolean true if credential is in allowed credentials
     *-------------------------------------------------*)
    function TDigestStaticCredentialsAuth.isAllowedCredential(
        const authCred : TCredential;
        const allowedCred : TCredentials
    ) : boolean;
    var indx, totCred : integer;
        response : string;
        digestInfo : PDigestInfo;
    begin
        result := false;
        digestInfo := PDigestInfo(authCred.data);
        totCred := length(allowedCred);
        for indx := 0 to totCred - 1 do
        begin
            if (allowedCred[indx].username = authCred.username) then
            begin
                response := calcDigestResponse(digestInfo, allowedCred[indx]);
                if response = digestInfo^.response then
                begin
                    //response matched, so credential is correct
                    result := true;
                    exit;
                end;
            end;
        end;
    end;

    (*!------------------------------------------------
     * authenticate credential
     *-------------------------------------------------
     * @param credential credential to authenticate
     * @return boolean true if credential is authenticated
     *-------------------------------------------------*)
    function TDigestStaticCredentialsAuth.auth(const credential : TCredential) : boolean;
    begin
        result := isAllowedCredential(credential, fAllowedCredentials);
    end;


end.

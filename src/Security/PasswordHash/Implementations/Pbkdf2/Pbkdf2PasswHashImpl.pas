{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit Pbkdf2PasswHashImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    InjectableObjectImpl,
    PasswordHashIntf;

type

    (*!------------------------------------------------
     * PBKDF2 password hash
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TPBKDF2PasswordHash = class (TInjectableObject, IPasswordHash)
    private
        fSalt : string;
        fCost : integer;
        fHashLen : integer;
    public
        constructor create(
            const defSalt : string = '';
            const defCost : integer = 1000;
            const defLen : integer = 64
        );

        (*!------------------------------------------------
         * set hash generator cost
         *-----------------------------------------------
         * @param algorithmCost cost of hash generator
         * @return current instance
         *-----------------------------------------------*)
        function cost(const algorithmCost : integer) : IPasswordHash;

        (*!------------------------------------------------
         * set hash length
         *-----------------------------------------------
         * @param hashLen length of hash
         * @return current instance
         *-----------------------------------------------*)
        function len(const hashLen : integer) : IPasswordHash;

        (*!------------------------------------------------
         * set password salt
         *-----------------------------------------------
         * @param saltValue salt
         * @return current instance
         *-----------------------------------------------*)
        function salt(const saltValue : string) : IPasswordHash;

        (*!------------------------------------------------
         * set secret key
         *-----------------------------------------------
         * @param secretValue a secret value
         * @return current instance
         *-----------------------------------------------*)
        function secret(const secretValue : string) : IPasswordHash;

        (*!------------------------------------------------
         * generate password hash
         *-----------------------------------------------
         * @param plainPassw input password
         * @return password hash
         *-----------------------------------------------*)
        function hash(const plainPassw : string) : string;

        (*!------------------------------------------------
         * verify plain password against password hash
         *-----------------------------------------------
         * @param plainPassw input password
         * @param hashedPassw password hash
         * @return true if password match password hash
         *-----------------------------------------------*)
        function verify(
            const plainPassw : string;
            const hashedPasswd : string
        ) : boolean;
    end;

implementation

uses
    Classes,
    SysUtils,
    HlpIHash,
    HlpHashFactory,
    HlpConverters,
    HlpSHA2_512,
    HlpIHashInfo;

    constructor TPBKDF2PasswordHash.create(
        const defSalt : string = '';
        const defCost : integer = 1000;
        const defLen : integer = 64
    );
    begin
        fSalt := defSalt;
        fCost := defCost;
        fHashLen := defLen;
    end;

    (*!------------------------------------------------
     * set hash generator cost
     *-----------------------------------------------
     * @param algorithmCost cost of hash generator
     * @return current instance
     *-----------------------------------------------*)
    function TPBKDF2PasswordHash.cost(const algorithmCost : integer) : IPasswordHash;
    begin
        fCost := algorithmCost;
        result := self;
    end;

    (*!------------------------------------------------
     * set hash length
     *-----------------------------------------------
     * @param hashLen length of hash
     * @return current instance
     *-----------------------------------------------*)
    function TPBKDF2PasswordHash.len(const hashLen : integer) : IPasswordHash;
    begin
        fHashLen := hashLen;
        result := self;
    end;

    (*!------------------------------------------------
     * set password salt
     *-----------------------------------------------
     * @param salt
     * @return current instance
     *-----------------------------------------------*)
    function TPBKDF2PasswordHash.salt(const saltValue : string) : IPasswordHash;
    begin
        fSalt := saltValue;
        result := self;
    end;

    (*!------------------------------------------------
     * set secret key
     *-----------------------------------------------
     * @param secretValue a secret value
     * @return current instance
     *-----------------------------------------------*)
    function TPBKDF2PasswordHash.secret(const secretValue : string) : IPasswordHash;
    begin
        //not relevant for PBKDF2_HMAC
        result := self;
    end;

    (*!------------------------------------------------
     * generate password hash
     *-----------------------------------------------
     * @param plainPassw input password
     * @return password hash
     *-----------------------------------------------*)
    function TPBKDF2PasswordHash.hash(const plainPassw : string) : string;
    var
        BytePassword, ByteSalt: TBytes;
        PBKDF2_HMACInstance: IPBKDF2_HMAC;
    begin
        BytePassword := TConverters.ConvertStringToBytes(plainPassw, TEncoding.UTF8);
        ByteSalt := TConverters.ConvertStringToBytes(fSalt, TEncoding.UTF8);

        PBKDF2_HMACInstance := TKDF.TPBKDF2_HMAC.CreatePBKDF2_HMAC(
            THashFactory.TCrypto.CreateSHA2_512(),
            BytePassword,
            ByteSalt,
            fCost
        );

        result := TConverters.ConvertBytesToHexString(
            PBKDF2_HMACInstance.GetBytes(fHashLen),
            false
        );
    end;

    (*!------------------------------------------------
     * verify plain password against password hash
     *-----------------------------------------------
     * @param plainPassw input password
     * @param hashedPassw password hash
     * @return true if password match password hash
     *-----------------------------------------------*)
    function TPBKDF2PasswordHash.verify(
        const plainPassw : string;
        const hashedPasswd : string
    ) : boolean;
    begin
        result := (hash(plainPassw) = hashedPasswd);
    end;
end.

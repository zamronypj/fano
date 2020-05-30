{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2020 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit BlowfishEncrypterImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    InjectableObjectImpl,
    EncrypterIntf,
    DecrypterIntf;

type

    (*!------------------------------------------------
     * class having capability to encrypt/decrypt string
     * using Blowfish algorithm and Base64
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TBlowfishEncrypter = class(TInjectableObject, IEncrypter, IDecrypter)
    private
        fSecretKey : string;
        function encodeBase64SpecialChars(const base64Str : string) : string;
        function decodeBase64SpecialChars(const base64Str : string) : string;
    public
        constructor create(const secretKey : string);

        (*!------------------------------------------------
         * encrypt string
         *-----------------------------------------------
         * @param originalStr original string
         * @return encrypted string
         *-----------------------------------------------*)
        function encrypt(const originalStr : string) : string;

        (*!------------------------------------------------
         * decrypt string
         *-----------------------------------------------
         * @param encryptedStr encrypted string
         * @return original string
         *-----------------------------------------------*)
        function decrypt(const encryptedStr : string) : string;

    end;

implementation

uses

    Classes,
    Base64,
    SysUtils,
    Blowfish;

    constructor TBlowfishEncrypter.create(const secretKey : string);
    begin
        fSecretKey := secretKey;
    end;

    function TBlowfishEncrypter.encodeBase64SpecialChars(const base64Str : string) : string;
    begin
        result := StringReplace(base64Str, '+', '.', [rfReplaceAll]);
        result := StringReplace(result, '/', '_', [rfReplaceAll]);
        result := StringReplace(result, '=', '-', [rfReplaceAll]);
    end;

    function TBlowfishEncrypter.decodeBase64SpecialChars(const base64Str : string) : string;
    begin
        result := StringReplace(base64Str, '.', '+', [rfReplaceAll]);
        result := StringReplace(result, '_', '/', [rfReplaceAll]);
        result := StringReplace(result, '-', '=', [rfReplaceAll]);
    end;

    (*!------------------------------------------------
     * encrypt string
     *-----------------------------------------------
     * @param originalStr original string
     * @return encrypted string
     *-----------------------------------------------
     * @author : leledumbo
     * @credit : http://pascalgeek.blogspot.com/2012/06/encryption-decryption-and-asynchronous.html
     *-----------------------------------------------*)
    function TBlowfishEncrypter.encrypt(const originalStr : string) : string;
    var blowfishEncryptor : TBlowFishEncryptStream;
        encryptedStream : TStringStream;
    begin
        encryptedStream := TStringStream.create('');
        try
            blowfishEncryptor := TBlowFishEncryptStream.create(
                fSecretKey,
                encryptedStream
            );
            try
                blowfishEncryptor.writeAnsiString(originalStr);
            finally
                blowfishEncryptor.free();
            end;

            //need to read encrypted string after free
            //see https://bugs.freepascal.org/view.php?id=36343
            result := encodeBase64SpecialChars(
                encodeStringBase64(encryptedStream.DataString)
            );
        finally
            encryptedStream.free();
        end;
    end;

    (*!------------------------------------------------
     * decrypt string
     *-----------------------------------------------
     * @param encryptedStr encrypted string
     * @return original string
     *-----------------------------------------------
     * @author : leledumbo
     * @credit : http://pascalgeek.blogspot.com/2012/06/encryption-decryption-and-asynchronous.html
     *-----------------------------------------------*)
    function TBlowfishEncrypter.decrypt(const encryptedStr : string) : string;
    var blowfishDecryptor: TBlowFishDeCryptStream;
        decryptedStream : TStringStream;
    begin
        decryptedStream := TStringStream.create(
            decodeStringBase64(decodeBase64SpecialChars(encryptedStr))
        );
        try
            blowfishDecryptor := TBlowFishDeCryptStream.create(
                fSecretKey,
                decryptedStream
            );
            try
                result := blowfishDecryptor.readAnsiString();
            finally
                blowfishDecryptor.free();
            end;
        finally
            decryptedStream.free();
        end;
    end;
end.

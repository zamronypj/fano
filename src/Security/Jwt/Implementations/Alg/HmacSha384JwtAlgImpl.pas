{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2020 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit HmacSha384JwtAlgImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    AbstractHmacJwtAlgImpl;

type

    (*!------------------------------------------------
     * class having capability to verify JWT token validity
     * with HMAC SHA-2 384
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    THmacSha384JwtAlg = class (TAbstractHmacJwtAlg)
    protected
        function hmac(const inpStr : string; const secretKey: string) : string; override;

    end;

implementation

uses

    SysUtils,
    HlpIHashInfo,
    HlpConverters,
    HlpHashFactory;

    function THmacSha384JwtAlg.hmac(
        const inpStr : string;
        const secretKey : string
    ) : string;
    var hmacInst : IHMAC;
    begin
        hmacInst := THashFactory.THMAC.CreateHMAC(
            THashFactory.TCrypto.CreateSHA2_384
        );
        hmacInst.Key := TConverters.ConvertStringToBytes(secretKey, TEncoding.UTF8);
        result := hmacInst.ComputeString(inpStr, TEncoding.UTF8).ToString();
    end;

end.

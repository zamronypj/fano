{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit RawSessionIdGeneratorImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    SessionIdGeneratorIntf,
    EnvironmentIntf,
    RandomIntf;

type

    (*!------------------------------------------------
     * basic class having capability to
     * generate session id
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TRawSessionIdGenerator = class(TInterfacedObject, ISessionIdGeneratorIntf)
    protected
        fEnv : ICGIEnvironment;
        fRandom : IRandom;

    public
        constructor create(const env : ICGIEnvironment; const randInst : IRandom);
        destructor destroy(); override;

        (*!------------------------------------
         * get session id
         *-------------------------------------
         * @return session id string
         *-------------------------------------*)
        function getSessionId() : string;
    end;

implementation

uses

    Unix,
    SysUtils,
    BaseUnix;

    constructor TRawSessionIdGenerator.create(const env : ICGIEnvironment; const randInst : IRandom);
    begin
        inherited create();
        fEnv := env;
        fRandom := randInst;
    end;

    destructor TRawSessionIdGenerator.destroy();
    begin
        fEnv := nil;
        fRandom := nil;
        inherited destroy();
    end;

    (*!------------------------------------
     * get session id
     *-------------------------------------
     * @return session id string
     *-------------------------------------*)
    function TRawSessionIdGenerator.getSessionId() : string;
    var rawSessionId : string;
        tv: TTimeVal;
    begin
        fpGetTimeOfDay (@tv, nil);
        result := format(
            '%s%d%d%s',
            [
                fEnv.remoteAddr(),
                tv.tv_sec,
                tv.tv_usec,
                stringOf(fRandom.randomBytes(32))
            ]
        );
    end;

end.

{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2021 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ThrottleRequestImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    RequestIntf,
    RateTypes,
    ThrottleRequestIntf,
    DecoratorRequestImpl;

type

    (*!------------------------------------------------
     * HTTP request with additional rate
     * limiting data
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TThrottleRequest = class (TDecoratorRequest, IRequest, IThrottleRequest)
    private
        fLimitStatus : TLimitStatus;
    public
        constructor create(const request : IRequest; const alimitStatus : TLimitStatus);

        (*!------------------------------------------------
         * get rate limit status
         *-------------------------------------------------
         * @return limit status of current request
         *------------------------------------------------*)
        function getLimitStatus() : TLimitStatus;
    end;

implementation

    constructor TThrottleRequest.create(const request : IRequest; const alimitStatus : TLimitStatus);
    begin
        inherited create(request);
        fLimitStatus := alimitStatus;
    end;

    (*!------------------------------------------------
     * get rate limit status
     *-------------------------------------------------
     * @return limit status of current request
     *------------------------------------------------*)
    function TThrottleRequest.getLimitStatus() : TLimitStatus;
    begin
        result := fLimitStatus;
    end;
end.

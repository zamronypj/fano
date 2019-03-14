{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit HttpAbstractFactoryImpl;

interface

{$MODE OBJFPC}

uses

    HttpClientHandleAwareIntf,
    FactoryImpl;

type
    (*!------------------------------------------------
     * Base factory class
     *-------------------------------------------------
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    THttpAbstractFactory = class(TFactory)
    private
        handleAware : IHttpClientHandleAware;
    public
        property handle : IHttpClientHandleAware read handleAware write handleAware;
    end;

implementation

end.

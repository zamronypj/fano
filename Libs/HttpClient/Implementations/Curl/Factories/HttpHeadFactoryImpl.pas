{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit HttpHeadFactoryImpl;

interface

{$MODE OBJFPC}

uses

    DependencyIntf,
    DependencyContainerIntf,
    HttpAbstractFactoryImpl;

type
    (*!------------------------------------------------
     * THttpHead factory class
     *------------------------------------------------
     * This class can serve as factory class for THttpHead
     * and also can be injected into dependency container
     * directly to build THttpHead class
     *-------------------------------------------------
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    THttpHeadFactory = class(THttpAbstractFactory)
    public
        (*!---------------------------------------------------
         * build class instance
         *----------------------------------------------------
         * @param container dependency container instance
         *----------------------------------------------------
         * This is implementation of IDependencyFactory
         *---------------------------------------------------*)
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses

    classes,
    HttpHeadImpl,
    HttpClientHeadersImpl,
    ResponseStreamImpl;

    (*!---------------------------------------------------
     * build class instance
     *----------------------------------------------------
     * @param container dependency container instance
     *---------------------------------------------------*)
    function THttpHeadFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := THttpHead.create(
            handle,
            THttpClientHeaders.create(handle),
            TResponseStream.create(TStringStream.create(''))
        );
    end;
end.

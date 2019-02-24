{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit HttpPostFactoryImpl;

interface

{$MODE OBJFPC}

uses

    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl;

type
    (*!------------------------------------------------
     * THttpPost factory class
     *------------------------------------------------
     * This class can serve as factory class for THttpPost
     * and also can be injected into dependency container
     * directly to build THttpPost class
     *-------------------------------------------------
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    THttpPostFactory = class(TFactory)
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
    HttpPostImpl,
    ResponseStreamImpl;

    (*!---------------------------------------------------
     * build class instance
     *----------------------------------------------------
     * @param container dependency container instance
     *---------------------------------------------------*)
    function THttpPostFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := THttpPost.create(
            TResponseStream.create(TStringStream.create(''))
        );
    end;
end.
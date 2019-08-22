{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit MiddlewareChainFactoryIntf;

interface

{$MODE OBJFPC}

uses

   MiddlewareChainIntf,
   MiddlewareCollectionAwareIntf;

type

    (*!------------------------------------------------
     * interface for any class having capability to create
     * middleware chain instance
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IMiddlewareChainFactory = interface
        ['{3D57F1EB-46CD-4D63-B77B-D51C656139EE}']

        function build(
            const appMiddlewares : IMiddlewareCollectionAware;
            const routeMiddlewares : IMiddlewareCollectionAware
        ) : IMiddlewareChain;
    end;

implementation

end.

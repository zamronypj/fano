{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit MiddlewareCollectionAwareFactoryIntf;

interface

{$MODE OBJFPC}

uses

   MiddlewareCollectionAwareIntf;

type

    (*!------------------------------------------------
     * interface for any class having capability to create
     * middleware collection aware instance
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IMiddlewareCollectionAwareFactory = interface
        ['{E935B73E-41B5-4C75-9940-EF6ABF5428D1}']

        function build() : IMiddlewareCollectionAware;
    end;

implementation

end.

{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit DecoratorSessionIdGeneratorImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    SessionIdGeneratorIntf;

type

    (*!------------------------------------------------
     * abstract decorator class having capability to
     * generate session id
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TDecoratorSessionIdGenerator = class(TInterfacedObject, ISessionIdGenerator)
    protected
        fActualGenerator : ISessionIdGeneratorIntf;
    public
        constructor create(const gen : ISessionIdGeneratorIntf);
        destructor destroy(); override;

        (*!------------------------------------
         * get session id
         *-------------------------------------
         * @return session id string
         *-------------------------------------*)
        function getSessionId() : string; virtual; abstract;
    end;

implementation

    constructor TDecoratorSessionIdGenerator.create(const gen : ISessionIdGeneratorIntf);
    begin
        inherited create();
        fActualGenerator := gen;
    end;

    destructor TDecoratorSessionIdGenerator.destroy();
    begin
        fActualGenerator := nil;
        inherited destroy();
    end;

end.

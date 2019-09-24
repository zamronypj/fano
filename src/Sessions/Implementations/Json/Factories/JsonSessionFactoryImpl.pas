{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit JsonSessionFactoryImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    SessionIntf,
    SessionFactoryIntf;

type

    (*!------------------------------------------------
     * factory class having capability to
     * create JsonSession object
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TJsonSessionFactory = class(TInterfacedObject, ISessionFactory)
    public
        function createSession(
            const sessName : shortstring;
            const sessId : shortstring;
            const sessData : string
        ) : ISession;
    end;

implementation

uses

    JsonSessionImpl;

    function TJsonSessionFactory.createSession(
        const sessName : shortstring;
        const sessId : shortstring;
        const sessData : string
    ) : ISession;
    begin
        result := TJsonSession.create(sessName, sessId, sessData);
    end;

end.

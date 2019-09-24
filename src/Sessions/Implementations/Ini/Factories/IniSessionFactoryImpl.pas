{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit IniSessionFactoryImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    SessionIntf,
    SessionFactoryIntf;

type

    (*!------------------------------------------------
     * factory class having capability to
     * create TIniSession object
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TIniSessionFactory = class(TInterfacedObject, ISessionFactory)
    public
        function createSession(
            const sessName : shortstring;
            const sessId : shortstring;
            const sessData : string
        ) : ISession;
    end;

implementation

uses

    IniSessionImpl;

    function TIniSessionFactory.createSession(
        const sessName : shortstring;
        const sessId : shortstring;
        const sessData : string
    ) : ISession;
    begin
        result := TIniSession.create(sessName, sessId, sessData);
    end;

end.

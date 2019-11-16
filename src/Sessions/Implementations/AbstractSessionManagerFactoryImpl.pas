{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit AbstractSessionManagerFactoryImpl;

interface

{$MODE OBJFPC}

uses

    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl,
    SessionConsts,
    SessionIdGeneratorFactoryIntf;

type
    (*!------------------------------------------------
     * base factory class for session manager
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TAbstractFileSessionManagerFactory = class(TFactory)
    protected
        fCookieName : string;
        fBaseDir : string;
        fPrefix : string;

        fSessionIdGeneratorFactory : ISessionIdGeneratorFactory;
    public
        constructor create(
            const cookieName : string = FANO_COOKIE_NAME;
            const baseDir : string = '/tmp';
            const prefix : string = ''
        );

        function sessionIdGenerator(const factory : ISessionIdGeneratorFactory) : TAbstractFileSessionManagerFactory;

    end;

implementation

uses

    GuidSessionIdGeneratorFactoryImpl;

    constructor TAbstractFileSessionManagerFactory.create(
        const cookieName : string = FANO_COOKIE_NAME;
        const baseDir : string = '/tmp';
        const prefix : string = ''
    );
    begin
        fCookieName := cookieName;
        fBaseDir := baseDir;
        fPrefix := prefix;
        fSessionIdGeneratorFactory := TGuidSessionIdGeneratorFactory.create();
    end;

    function TAbstractFileSessionManagerFactory.sessionIdGenerator(const factory : ISessionIdGeneratorFactory) : TAbstractFileSessionManagerFactory;
    begin
        fSessionIdGeneratorFactory := factory;
        result := self;
    end;

end.

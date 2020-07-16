{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2020 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit IndyMailerFactoryImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl,
    IndyTypes;

type

    (*!------------------------------------------------
     * factory class for TIndyMailer
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *--------------------------------------------------*)
    TIndyMailerFactory = class(TFactory, IDependencyFactory)
    private
        fConfig : TSmtpConfig;
    public
        constructor create();

        function host(const sHost : string) : TIndyMailerFactory;
        function port(const sPort : word) : TIndyMailerFactory;
        function username(const sUsername : string) : TIndyMailerFactory;
        function password(const sPasw : string) : TIndyMailerFactory;

        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses

    IndyMailerImpl;

    constructor TIndyMailerFactory.create();
    begin
        fConfig := default(TSmtpConfig);
        fConfig.host := 'localhost';
        fConfig.port := 25;
        fConfig.timeout := 5000;
    end;

    function TIndyMailerFactory.host(const sHost : string) : TIndyMailerFactory;
    begin
        fConfig.host := sHost;
        result := self;
    end;

    function TIndyMailerFactory.port(const sPort : word) : TIndyMailerFactory;
    begin
        fConfig.port := sPort;
        result := self;
    end;

    function TIndyMailerFactory.username(const sUsername : string) : TIndyMailerFactory;
    begin
        fConfig.username := sUsername;
        result := self;
    end;

    function TIndyMailerFactory.password(const sPasw : string) : TIndyMailerFactory;
    begin
        fConfig.password := sPasw;
        result := self;
    end;

    function TIndyMailerFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TIndyMailer.create(fConfig);
    end;

end.

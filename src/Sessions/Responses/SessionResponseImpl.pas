(*!------------------------------------------------------------
 * Fano Web Framework Skeleton Application (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano-session
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano-app-middleware/blob/master/LICENSE (GPL 3.0)
 *------------------------------------------------------------- *)
unit SessionResponseImpl;

interface

uses

    ResponseIntf,
    SessionIntf,
    HeadersIntf,
    CookieIntf,
    CookieFactoryIntf,
    InjectableObjectImpl;

type

    (*!------------------------------------------------
     * Response implementation which add headers for
     * session data as cookie
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TSessionResponse = class(TInjectableObject, IResponse)
    private
        fResponse : IResponse;
        fSession : ISession;
        fCookieFactory : ICookieFactory;

        function addHeaders(
            const hdrs : IHeaders;
            const sess : ISession;
            const cookieFactory : ICookieFactory
        ) : IResponse;
    public
        constructor create(
            aResponse : IResponse;
            aSession : ISession;
            cookieFactory : ICookieFactory
        );
        destructor destroy(); override;

        property response : IResponse read fResponse implements IResponse;
    end;

implementation

    constructor TSessionResponse.create(
        aResponse : IResponse;
        aSession : ISession;
        cookieFactory : ICookieFactory
    );
    begin
        inherited create();
        fResponse := aResponse;
        fSession := aSession;
        fCookieFactory := cookieFactory;
        addHeaders(fResponse.headers(), fSession, fCookieFactory);
    end;

    destructor TSessionResponse.destroy();
    begin
        fCookieFactory := nil;
        fSession := nil;
        fResponse := nil;
        inherited destroy();
    end;

    function TSessionResponse.addHeaders(
        const hdrs : IHeaders;
        const sess : ISession;
        const cookieFactory : ICookieFactory
    ) : IResponse;
    var cookie : ICookie;
    begin
        cookie := cookieFactory.name(sess.name()).value(sess.id()).build();
        try
            hdrs.setHeader('Set-Cookie', cookie.serialize());
            result := self;
        finally
            cookie := nil;
        end;
    end;

end.

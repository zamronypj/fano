(*!------------------------------------------------------------
 * Fano Web Framework Skeleton Application (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano-session
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano-app-middleware/blob/master/LICENSE (GPL 3.0)
 *------------------------------------------------------------- *)
unit SessionEndMiddleware;

interface

uses

    MiddlewareIntf,
    SessionManagerIntf,
    RequestIntf,
    ResponseIntf,
    AbstractSessionMiddleware;

type

    (*!------------------------------------------------
     * middleware implementation that persist session
     * data to storage at the end of request
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TSessionEndMiddleware = class(TAbstractSessionMiddleware)
    public
        function handleRequest(
            const request : IRequest;
            const response : IResponse;
            var canContinue : boolean
        ) : IResponse;
    end;

implementation

    function TSessionEndMiddleware.handleRequest(
          const request : IRequest;
          const response : IResponse;
          var canContinue : boolean
    ) : IResponse;
    var sess : ISession;
        cookie : ICookie;
    begin
        sess := fSession.getSession(request);
        fSession.endSession(sess);
        cookie := TCookie.create(sess);
        result := TCookieResponse.create(response, cookie);
    end;

end.

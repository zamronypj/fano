{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit AuthIntf;

interface

{$MODE OBJFPC}
{$H+}

uses

    RequestIntf,
    ResponseIntf,
    RouteArgsReaderIntf;

type

    (*!------------------------------------------------
     * interface for any class having capability to
     * handle Cross-Origin Resource Sharing request
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TBasicAuth = class abstract (TInterfacedObject, IAuth)
    protected
        function getCredential(
            const request : IRequest;
            out username : string;
            out password : string
        ) : boolean;
    public


        (*!------------------------------------------------
         * handle authentication
         *-------------------------------------------------
         * @param request current request object
         * @param response current response object
         * @param args route argument reader
         * @return boolean true if request is authenticated
         *-------------------------------------------------*)
        function auth(
            const request : IRequest;
            const response : IResponse;
            const args : IRouteArgsReader
        ) : boolean; virtual; abstract;

    end;

implementation

uses

    SysUtils,
    Base64;

    (*!------------------------------------------------
     * extract username password from Basic Authentatication
     *-------------------------------------------------
     * @param request current request object
     * @param username extracted username
     * @param password extracted password
     * @return boolean true if username/password succesfully read
     *-------------------------------------------------*)
    function TBasicAuth.getCredential(
        const request : IRequest;
        out username : string;
        out password : string
    ) : boolean;
    var
        authHeaderLine : string;
        credential : string;
        colonPos : integer;
    begin
        result := false;
        if request.headers().has('Authorization') then
        begin
            authHeaderLine := request.headers().getHeader('Authorization');
            if pos('basic ', lowercase(authHeaderLine)) = 1 then
            begin
                credential := decodeStringBase64(
                    copy(
                        authHeaderLine,
                        7,
                        length(authHeaderLine) - 7
                    )
                );

                colonPos := pos(':', credential);
                if colonPos <> 0 then
                begin
                    username := copy(credential, 1, colonPos);
                    password := copy(credential, colonPos, length(credential) - colonPos);
                    result := true;
                end;
            end;
        end;
    end;

end.

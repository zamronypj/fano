{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit FcgiRequestImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    FcgiProcessorIntf,
    FcgiFrameParserIntf;

type

    (*!-----------------------------------------------
     * FastCGI request that implements IRequest
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiRequest = class(TInterfacedObject, IFcgiRequest, IRequest)
    private
        fRequest : IRequest;
        fRequestId : word;
    public
        (*!-----------------------------------------------
         * constructor
         *------------------------------------------------
         * @param id, request id
         * @param request, IRequest implementation
         *-----------------------------------------------*)
        constructor create(const id : word; const request : IRequest);

        (*!-----------------------------------------------
         * destructor
         *-----------------------------------------------*)
        destructor destroy(); override;

        (*!------------------------------------------------
        * get current request id
        *-----------------------------------------------
        * @return id of current request
        *-----------------------------------------------*)
        function id() : word;

        //delegate IRequest interface to fRequest
        property request : IRequest read fRequest implements IRequest;
    end;

implementation

    (*!-----------------------------------------------
     * constructor
     *------------------------------------------------
     * @param parser FastCGI frame parser
     *-----------------------------------------------*)
    constructor TFcgiRequest.create(const id : word; const request : IRequest);
    begin
        inherited create();
        fRequestId := id;
        fRequest := request;
    end;

    destructor TFcgiRequest.destroy();
    begin
        fRequest := nil;
        inherited destroy();
    end;

    (*!------------------------------------------------
    * get current request id
    *-----------------------------------------------
    * @return id of current request
    *-----------------------------------------------*)
    function TFcgiRequest.id() : word;
    begin
        result := fRequestId;
    end;

end.

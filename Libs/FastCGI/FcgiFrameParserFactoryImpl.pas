{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FcgiFrameParserFactoryImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    InjectableObjectImpl,
    FcgiFrameParserIntf;

type

    (*!-----------------------------------------------
     * FastCGI Frame Parser Factory
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiFrameParserFactory = class (TInjectableObject)
    private
    public
        function build() : IFcgiFrameParser;
    end;

implementation

uses

    fastcgi,

    FcgiRecordFactoryIntf,

    FcgiBeginRequestFactory,
    FcgiAbortRequestFactory,
    FcgiEndRequestFactory,
    FcgiParamsFactory,
    FcgiStdInFactory,
    FcgiStdOutFactory,
    FcgiStdErrFactory,
    FcgiDataFactory,
    FcgiGetValuesFactory,
    FcgiGetValuesResultFactory,
    FcgiUnknownTypeFactory;

    (*!------------------------------------------------
     * build fastCGI frame parser
     *-----------------------------------------------*)
    function TFcgiFrameParserFactory.build() : IFcgiFrameParser;
    var factories : array of IFcgiRecordFactory;
    begin
        setLength(factories, FCGI_MAXTYPE + 1);

        //FCGI_BEGIN_REQUEST = 1, FCGI_ABORT_REQUEST =2, and so on
        //this is provided so we can get factory by record type on zero-based array
        //without having to offset
        //so to access correct factory by record type, it simply factories[fcgiRec.reqtype]
        factories[0] := nil;

        factories[FCGI_BEGIN_REQUEST] := TFcgiBeginRequestFactory.create();
        factories[FCGI_ABORT_REQUEST] := TFcgiAbortRequestFactory.create();
        factories[FCGI_END_REQUEST] := TFcgiEndRequestFactory.create();
        factories[FCGI_PARAMS] := TFcgiParamsFactory.create();
        factories[FCGI_STDIN] := TFcgiStdInFactory.create();
        factories[FCGI_STDOUT] := TFcgiStdOutFactory.create();
        factories[FCGI_STDERR] := TFcgiStdErrFactory.create();
        factories[FCGI_DATA] := TFcgiDataFactory.create();
        factories[FCGI_GET_VALUES] := TFcgiGetValuesFactory.create();
        factories[FCGI_GET_VALUES_RESULT] := TFcgiGetValuesResultFactory.create();
        factories[FCGI_UNKNOWN_TYPE] := TFcgiUnknownTypeFactory.create();

        result := TFcgiFrameParser.create(factories);
    end;

end.

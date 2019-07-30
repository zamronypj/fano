{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FcgiNonBlockingParserFactoryImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    InjectableObjectImpl,
    FcgiFrameParserIntf,
    FcgiFrameParserFactoryIntf,
    FcgiBaseParserFactoryImpl;

type

    (*!-----------------------------------------------
     * FastCGI Non blocking Parser Factory
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiNonBlockingParserFactory = class (TFcgiBaseParserFactory)
    public
        (*!------------------------------------------------
         * build frame parser instance
         *-----------------------------------------------
         * @return frame parser instance
         *-----------------------------------------------*)
        function build() : IFcgiFrameParser; override;
    end;

implementation

uses

    MemAllocatorImpl,
    FcgiNonBlockingParserImpl;

    (*!------------------------------------------------
     * build frame parser instance
     *-----------------------------------------------
     * @return frame parser instance
     *-----------------------------------------------*)
    function TFcgiNonBlockingParserFactory.build() : IFcgiFrameParser;
    var mem : TMemAllocator;
    begin
        mem := TMemAllocator.create();
        result := TFcgiNonBlockingParser.create(createRecordFactories(), mem, mem);
    end;

end.

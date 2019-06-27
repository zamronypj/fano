TOutputBufferFactory = OutputBufferFactoryImpl.TOutputBufferFactory;
TStdErrBufferFactory = StdErrBufferFactoryImpl.TStdErrBufferFactory;

TFileLogger = FileLoggerImpl.TFileLogger;
TFileLoggerFactory = FileLoggerFactoryImpl.TFileLoggerFactory;
TNullLogger = NullLoggerImpl.TNullLogger;
TNullLoggerFactory = NullLoggerFactoryImpl.TNullLoggerFactory;
TCompositeLogger = CompositeLoggerImpl.TCompositeLogger;
TCompositeLoggerFactory = CompositeLoggerFactoryImpl.TCompositeLoggerFactory;

TStringFileReader = StringFileReaderImpl.TStringFileReader;
TStringFileReaderFactory = StringFileReaderFactoryImpl.TStringFileReaderFactory;

TStreamAdapter = StreamAdapterImpl.TStreamAdapter;
EInvalidStream = EInvalidStreamImpl.EInvalidStream;

TStdInReader = StdInReaderImpl.TStdInReader;
TSimpleStdInReader = SimpleStdInReaderImpl.TSimpleStdInReader;

THttpCurl = HttpCurlImpl.THttpCurl;
THttpCurlFactory = HttpCurlFactoryImpl.THttpCurlFactory;
THttpClientHeaders = HttpClientHeadersImpl.THttpClientHeaders;


THttpGet = HttpGetImpl.THttpGet;
THttpGetFactory = HttpGetFactoryImpl.THttpGetFactory;
THttpGetLogFactory = HttpGetLogFactoryImpl.THttpGetLogFactory;

THttpPost = HttpPostImpl.THttpPost;
THttpPostFactory = HttpPostFactoryImpl.THttpPostFactory;

THttpPut = HttpPutImpl.THttpPut;
THttpPutFactory = HttpPutFactoryImpl.THttpPutFactory;

THttpDelete = HttpDeleteImpl.THttpDelete;
THttpDeleteFactory = HttpDeleteFactoryImpl.THttpDeleteFactory;

THttpHead = HttpHeadImpl.THttpHead;
THttpHeadFactory = HttpHeadFactoryImpl.THttpHeadFactory;

TKeyValuePair = KeyValuePairImpl.TKeyValuePair;
TKeyValuePairFactory = KeyValuePairFactoryImpl.TKeyValuePairFactory;

{------------ Begin FastCGI-related------------------}
TFcgiAbortRequest = FcgiAbortRequest.TFcgiAbortRequest;
TFcgiBeginRequest = FcgiBeginRequest.TFcgiBeginRequest;
TFcgiData = FcgiData.TFcgiData;
TFcgiEndRequest = FcgiEndRequest.TFcgiEndRequest;
TFcgiGetValues = FcgiGetValues.TFcgiGetValues;
TFcgiGetValuesResult = FcgiGetValuesResult.TFcgiGetValuesResult;
TFcgiStdIn = FcgiStdIn.TFcgiStdIn;
TFcgiStdOut = FcgiStdOut.TFcgiStdOut;
TFcgiStdErr = FcgiStdErr.TFcgiStdErr;
TFcgiUnknownType = FcgiUnknownType.TFcgiUnknownType;

TFcgiAbortRequestFactory = FcgiAbortRequestFactory.TFcgiAbortRequestFactory;
TFcgiBeginRequestFactory = FcgiBeginRequestFactory.TFcgiBeginRequestFactory;
TFcgiDataFactory = FcgiDataFactory.TFcgiDataFactory;
TFcgiEndRequestFactory = FcgiEndRequestFactory.TFcgiEndRequestFactory;
TFcgiGetValuesFactory = FcgiGetValuesFactory.TFcgiGetValuesFactory;
TFcgiGetValuesResultFactory = FcgiGetValuesResultFactory.TFcgiGetValuesResultFactory;
TFcgiStdInFactory = FcgiStdInFactory.TFcgiStdInFactory;
TFcgiStdOutFactory = FcgiStdOutFactory.TFcgiStdOutFactory;
TFcgiStdErrFactory = FcgiStdErrFactory.TFcgiStdErrFactory;
TFcgiUnknownTypeFactory = FcgiUnknownTypeFactory.TFcgiUnknownTypeFactory;

TFcgiStdOutWriter = FcgiStdOutWriterImpl.TFcgiStdOutWriter;
TFcgiRequestManager = FcgiRequestManagerImpl.TFcgiRequestManager;
TFcgiFrameParser = FcgiFrameParserImpl.TFcgiFrameParser;
TFcgiProcessor = FcgiProcessorImpl.TFcgiProcessor;
{------------ End FastCGI-related------------------}

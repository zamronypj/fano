unit RegexRouteListImpl;

interface

{$H+}

uses
    RouteListIntf,
    HashListImpl,
    RegexIntf;

type
    TPlaceholder = record
        phName : string;
        phValue : string;
        phFormatRegex : string;
    end;
    TArrayOfPlaceholders = array of TRoutePlaceholder;

    {------------------------------------------------
     interface for any class having capability to
     handler route
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TRegexRouteList = class(THashList, IRouteList)
    private
        regex : IRegex;

        function getPlaceholderFromOriginalRoute(
            const originalRouteWithRegex : string
        ) : TArrayOfPlaceholders;

        function replacePlaceholderRegexWithDispatherRegex(
            const originalRouteWithRegex : string
        ) : string;
    public
        constructor create(const regexInst : IRegex);
        destructor destroy(); override;

        function add(const routeName : string; const routeData : pointer) : integer;
        function find(const routeName : string) : pointer;
    end;

implementation

const
    (*-------------------------------------------------
      regex pattern that will match following string format
      and extract placeholder variable name inside {}
      and optional regex (if any)

      /store/{ storeId }/feedback
      /name/{name:[a-zA-Z0-9\-\*\:]+}/{unitId}/edback
      /name/{tr : [a-zA-Z0-9]*? }/{unitId}/edback
    -------------------------------------------------*)
    ROUTE_PLACEHOLDER_REGEX = '\{\s*([a-zA-Z_][a-zA-Z0-9_-]*)\s*(?:\:\s*([^{}]*(?:\{(?-1)\}[^{}]*)*))?\}';

    (*-------------------------------------------------
      regex pattern that will be used to replace original
      route pattern. The replaced route pattern md5-hashed
      will be stored inside list
    -------------------------------------------------*)
    ROUTE_DISPATCH_REGEX = '[^/]+';

type

    TRouteDataRec = record
        placeholders: TArrayOfPlaceholders;
        routeData : pointer;
    end;
    PRouteDataRec = ^TRouteDataRec;

    (*------------------------------------------------
      get placeholder variable original
      for example for route pattern :
        /name/{name:[a-zA-Z0-9\-\*\:]+}/{unitId}/edback
      and actual Request Uri
        /name/juhara/nice/edback

      into array of placeholder
      [
        {
          phName : 'name'
          phValue : 'juhara'
          phFormatRegex : '[a-zA-Z0-9\-\*\:]+',
        }
        {
          phName : 'unitId'
          phValue : 'nice'
          phFormatRegex : ''
        }
      ]
      /name/[^/]+/[^/]+/edback

      See ROUTE_DISPATCH_REGEX constant
    ---------------------------------------------------*)
    function TRegexRouteList.getPlaceholderFromOriginalRoute(
        const originalRouteWithRegex : string
    ) : TArrayOfPlaceholders;
    begin

    end;

    (*------------------------------------------------
     * replace original route pattern :
     *   /name/{name:[a-zA-Z0-9\-\*\:]+}/{unitId}/edback
     *
     * into route pattern ready for dispatch
     * /name/[^/]+/[^/]+/edback
     *
     * See ROUTE_DISPATCH_REGEX constant
     *---------------------------------------------------*)
    function TRegexRouteList.replacePlaceholderRegexWithDispatherRegex(
        const originalRouteWithRegex : string;
        const placeholders : TArrayOfPlaceholders
    ) : string;
    var i: integer;
    begin
        matched := regex.match(
            originalRouteWithRegex,
            ROUTE_PLACEHOLDER_REGEX,
            matchGroup
        );
        if (matched) then
        begin
            for i := 0 to leng(matched)-1 do
            begin

            end;
        end;
    end;

    constructor TRegexRouteList.create(const regexInst : IRegex);
    begin
        regex := regexInst;
    end;

    destructor TRegexRouteList.destroy();
    begin
        inherited destroy();
        regex := nil;
    end;

    (*!------------------------------------------------
     * add route pattern to list
     *-------------------------------------------------
     * @param routeName original route as defined by app
     *   /name/{name:[a-zA-Z0-9\-\*\:]+}/{unitId}/edback
     * @param routeData, pointer to route data (such handler, etc)
     * @return integer index of added item in list
     *-------------------------------------------------
     *
     * If we have following input route name
     *   /name/{name:[a-zA-Z0-9\-\*\:]+}/{unitId}/edback
     * (1) we will extract placeholder data
     *     into array of placeholder
     *     [
     *         {
     *             phName : 'name'
     *             phFormaRegex : '[a-zA-Z0-9\-\*\:]+',
     *         },
     *         {
     *             phName : 'unitId'
     *             phFormatRegex : ''
     *         }
     *     ]
     * (2) replace route name into new regex string (transformed route name) as
     *   /name/[^/]+/[^/]+/edback
     * (3) store transformed route name into list
     *---------------------------------------------------*)
    function TRegexRouteList.add(const routeName : string; const routeData : pointer) : integer;
    var replacedRoutePattern : string;
        placeholders : TArrayOfPlaceholders;
    begin
        placeholders := getPlaceholderFromOriginalRoute(routeName);
        replacedRoutePattern := regex.replace();

        result := inherited add(routeName, routeData);
    end;

    function TRegexRouteList.combineRegexRoutes() : string;
    var i, len : integer;
    begin
        //if we get here, it is assumed that count will be > 0
        result := '(?:';
        len := count();
        for i:=0 to len-1 do
        begin
            routeRegex := keyOfIndex(i);
            if (i < len-1) then
            begin
                result := result + routeRegex +'|';
            end else
            begin
                result := result + routeRegex;
            end;
        end;
        result := result + ')';
    end;

    (*------------------------------------------------
     * match request uri with route list
     *------------------------------------------------
     * @param requestUri, original request uri
     * @return routeData of matched route
     *-------------------------------------------------
     * For example, if we have following uri
     *   /name/juhara/nice/edback
     * and following registered route patterns
     *  (1) /name/([^/]+)/([^/]+)/edback
     *  (2) /article/([^/]+)/([^/]+)
     *  (3) /articles/([^/]+)/([^/]+)
     *
     * (i) We will combine all registered route patterns in list into one
     * string regex in form, so we can match all routes using only one
     * regex matching call. (?:) is non capturing group so only inside parenthesis
     * that will be captured
     *
     *  (?:
     *  (/name/([^/]+)/([^/]+)/edback)|
     *  (/article/([^/]+)/([^/]+)|
     *  (/articles/([^/]+)/([^/]+)
     *  )
     *
     * (ii) Based on matched group (the second non empty group),
     * we can get index to the list of routes list.
     * (iii) parse capture group based on its placeholder to get value
     * (iv) return route data with its placeholder data
     *---------------------------------------------------*)
    function TRegexRouteList.find(const requestUri : string) : pointer;
    var combinedRegex : string;
        matches : TRegexMatchResult;
        placeholderRegex : TRegexMatchResult;
    var data :PRouteDataRec;
    begin
        if (emptyRoutes()) then
        begin
            result := nil;
            exit;
        end;

        combinedRegex := combineRegexRoutes();
        matches := regex.match(combinedRegex, requestUri);
        if (matches.matched) then
        begin
            data := inherited find(matches.matches[0]);
            if (data <> nil) then
            begin
                if (length(data.phFormatRegex) > 0) then
                begin
                    //if we get here, placeholder expect value to be in format
                    //as specified by phFormatRegex, test further
                    placeholherRegex := regex.match(data.formatRegex, matches.matches[0]);
                    if (placeholderRegex.matched) then
                    begin
                        data.phValue := matches.matches[0];
                    end else
                    begin
                        //assume not found or some other value
                        result := nil;
                    end;
                end else
                begin
                    data.phValue := matches.matches[0];
                end;
                //TODO:return also placeholder!!
                result := data.routeData;
            end else
            begin
                result := nil;
            end;
        end else
        begin
            result := nil;
        end;
    end;

end.

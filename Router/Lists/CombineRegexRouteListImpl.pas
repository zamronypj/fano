{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit CombineRegexRouteListImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    HashListIntf,
    RouteListIntf,
    HashListImpl,
    RegexIntf,
    PlaceholderTypes,
    RouteDataTypes;

type

    (*!------------------------------------------------
     * class that store list of routes patterns and its
     * associated data and match uri to retrieve matched
     * patterns and its data.
     *
     * This class match all routes using one regex matching
     * by combining all route patterns
     * as one big regex pattern.
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     * -----------------------------------------------*)
    TCombineRegexRouteList = class(TInterfacedObject, IHashList, IRouteList)
    private
        regex : IRegex;
        hashesList : IHashList;

        function getPlaceholderFromOriginalRoute(
            const originalRouteWithRegex : string
        ) : TArrayOfPlaceholders;

        function getPlaceholderValuesFromUri(
             const matches : TRegexMatchResult;
             const placeHolders : TArrayOfPlaceholders
        ) : TArrayOfPlaceholders;

        procedure clearRoutes();
        function findRoute(const requestUri : string) : PRouteRec;

        function findRouteByMatchIndex(const matchIndex : integer) : PRouteRec;

        function combineRegexRoutes() : string;
        function findMatchedRoute(const matchResult : TRegexMatchResult) : PRouteRec;
        function translateRouteName(const originalRouteWithRegex : string) : string;
    public
        constructor create(const regexInst : IRegex; const hashes : IHashList);
        destructor destroy(); override;

        (*!------------------------------------------------
         * add route pattern to list
         *-------------------------------------------------
         * @param routeName original route as defined by app
         *   /name/{name}/{unitId}/edback
         * @param routeData, pointer to route data (such handler, etc)
         * @return integer index of added item in list
         *---------------------------------------------------*)
        function add(const routeName : shortstring; const routeData : pointer) : integer;

        (*------------------------------------------------
         * match request uri with route list and return
         * its associated data
         *---------------------------------------------------*)
        function match(const requestUri : shortstring) : pointer;

        (*------------------------------------------------
         * match request uri with route list and return
         * its associated data
         *---------------------------------------------------*)
        function find(const key : shortstring) : pointer;

        function count() : integer;
        function get(const indx : integer) : pointer;
        procedure delete(const indx : integer);
        function keyOfIndex(const indx : integer) : shortstring;
    end;

implementation

uses

    sysutils,
    ERouteMatcherImpl;

resourcestring

    sTotalPlaceHolderAndValueNotEqual = 'Number of variable placeholders (%d) and values (%d) not equal.';

const
    (*-------------------------------------------------
      regex pattern that will match following string format
      and extract placeholder variable name inside {}

      /store/{ storeId }/feedback
      /name/{name-id}/{unitId}/edback
      /name/{name}/{unitId}/edback
      /name/{ tr }/{unitId}/edback

      This class DOES NOT support syntax such as
      /store/{storeId:[a-zA-Z0-9]+}/feedback
    -------------------------------------------------*)
    ROUTE_PLACEHOLDER_REGEX = '\{\s*([a-zA-Z_][a-zA-Z0-9_\-]*)\s*\}';

    (*-------------------------------------------------
      regex pattern that will be used to replace original
      route pattern. The replaced route pattern md5-hashed
      will be stored inside list
    -------------------------------------------------*)
    ROUTE_DISPATCH_REGEX = '([^/]+)';

    constructor TCombineRegexRouteList.create(const regexInst : IRegex; const hashes : IHashList);
    begin
        hashesList := hashes;
        regex := regexInst;
    end;

    destructor TCombineRegexRouteList.destroy();
    begin
        inherited destroy();
        clearRoutes();
        regex := nil;
        hashesList := nil;
    end;

    procedure TCombineRegexRouteList.clearRoutes();
    var i, len : integer;
    begin
        len := count();
        for i := len -1 downto 0 do
        begin
            hashesList.delete(i);
        end;
    end;

    (*------------------------------------------------
     * get placeholder variable original
     *------------------------------------------------
     * for example for route pattern :
     *  /name/{name}/{unitId}/edback
     *
     *  It will returns array of placeholder like below
     *
     * [
     *  {
     *    phName : 'name',
     *    phValue : '',
     *  }
     *  {
     *    phName : 'unitId',
     *    phValue : '',
     *  }
     * ]
     *
     * This method will be called when a route pattern is
     * added to route collection. At this time,
     * placeholder value is not yet known ,so phValue field
     * will always be empty
     *
     *---------------------------------------------------*)
    function TCombineRegexRouteList.getPlaceholderFromOriginalRoute(
        const originalRouteWithRegex : string
    ) : TArrayOfPlaceholders;
    var matches : TRegexMatchResult;
        i, totalPlaceholder : integer;
    begin
        matches := regex.greedyMatch(
            ROUTE_PLACEHOLDER_REGEX,
            originalRouteWithRegex
        );

        if (not matches.matched) then
        begin
            result := nil;
            exit;
        end;

        totalPlaceholder := length(matches.matches);

        (*----------------------------
          if route is registered as:
          /name/{name}/{unitId}/edback

          matches will contain following data:

          length(matches.matches) == 2
          matches.matched = true
          matches.matches[0][0] = '{name}'
          matches.matches[0][1] = 'name'
          matches.matches[1][0] = '{unidId}'
          matches.matches[1][1] = 'unitId'

          So to extract variable names, we
          only need to extract from

          matches.matches[n][1]
          where n=0..length(matches.matches)-1
         ----------------------------*)
        setLength(result, totalPlaceholder);
        for i:=0 to totalPlaceholder-1 do
        begin
            result[i].phName := matches.matches[i][1];
            result[i].phValue := '';
        end;
    end;

    (*------------------------------------------------
     * get placeholder value from uri
     *------------------------------------------------
     * after a route is matched, then this method will be
     * called with matched route, original uri and placeholder
     * for example for route pattern :
     *  /name/{name}/{unitId}/edback
     * and actual Request Uri
     * /name/juhara/nice/edback
     *
     *  It will returns array of placeholder like below
     *
     * [
     *  {
     *    phName : 'name'
     *    phValue : 'juhara'
     *  }
     *  {
     *    phName : 'unitId'
     *    phValue : 'nice'
     *  }
     * ]
     *
     *---------------------------------------------------*)
    function TCombineRegexRouteList.getPlaceholderValuesFromUri(
         const matches : TRegexMatchResult;
         const placeHolders : TArrayOfPlaceholders
    ) : TArrayOfPlaceholders;
    var i, totalValue, totalPlaceHolders : longint;
    begin
        totalPlaceHolders := length(placeholders);
        //matches.matches will always contain 1 element
        //totalValue will contain number of placeholder+1 (full match)
        totalValue := length(matches.matches[0])-1;

        if (totalPlaceHolders <> totalValue) then
        begin
            //Something is wrong as both must be equal!
            raise ERouteMatcher.createFmt(
                sTotalPlaceHolderAndValueNotEqual,
                [totalPlaceHolders, totalValue]
            )
        end;

        (*----------------------------
          if we get here then placeholders will contain
          data that is same as output getPlaceholderFromOriginalRoute
          So we do not need to call setLength() anymore

          if request uri is
          /name/juhara/nice/edback

          matches will contain following data:

          length(matches.matches) == 3
          matches.matched = true
          matches.matches[0][0] = '/name/juhara/nice/edback'

          matches.matches[0][1] = 'juhara'

          matches.matches[0][2] = 'nice'

          So to extract value names, we
          only need to extract from

          matches.matches[0][n]
          where n=1..length(matches.matches)-1
         ----------------------------*)
        for i:=0 to totalPlaceholders-1 do
        begin
            //placeholders[i].phName already contain variable name
            //so our concern only to fill its value
            placeholders[i].phValue := matches.matches[0][i+1];
        end;
        result := placeHolders;
    end;

    (*------------------------------------------------
     * replace original route pattern with regex pattern
     * ready for dispatch
     * ----------------------------------------------
     * @param originalRouteWithRegex original route pattern
     * @return transformedRouteName
     * -----------------------------------------------
     * replace original route pattern :
     *   /name/{name}/{unitId}/edback
     *
     * into route pattern ready for dispatch
     * /name/([)^/]+)/([^/]+)/edback
     *
     * See ROUTE_DISPATCH_REGEX constant
     *---------------------------------------------------*)
    function TCombineRegexRouteList.translateRouteName(const originalRouteWithRegex : string) : string;
    begin
        result := regex.replace(
            ROUTE_PLACEHOLDER_REGEX,
            originalRouteWithRegex,
            ROUTE_DISPATCH_REGEX
        );
    end;

    (*!------------------------------------------------
     * add route pattern to list
     *-------------------------------------------------
     * @param routeName original route as defined by app
     *   /name/{name}/{unitId}/edback
     * @param routeData, pointer to route data (such handler, etc)
     * @return integer index of added item in list
     *-------------------------------------------------
     *
     * If we have following input route name
     *   /name/{name}/{unitId}/edback
     * (1) we will extract placeholder data
     *     into array of placeholder
     *     [
     *         {
     *             phName : 'name',
     *             phValue : ''
     *         },
     *         {
     *             phName : 'unitId'
     *             phValue : ''
     *         }
     *     ]
     * (2) replace route name into new regex string (transformed route name) as
     *   /name/([^/]+)/([^/]+)/edback
     * (3) store transformed route name into list
     *---------------------------------------------------*)
    function TCombineRegexRouteList.add(const routeName : shortstring; const routeData : pointer) : integer;
    var routeRec : PRouteRec;
    begin
        routeRec := routeData;
        routeRec^.placeholders := getPlaceholderFromOriginalRoute(routeName);
        result := hashesList.add(translateRouteName(routeName), routeRec);
    end;

    (*------------------------------------------------
     * combine route regex pattern inside list as one
     * long regex string
     *------------------------------------------------
     * @return combined route regex string
     *-------------------------------------------------
     * For example, if we have following registered route patterns
     *  (1) /name/([^/]+)/([^/]+)/edback
     *  (2) /article/([^/]+)/([^/]+)
     *  (3) /nice-articles/([^/]+)/([^/]+)
     *
     * We will combine all registered route patterns in list into one
     * string regex, in following format
     *
     *  ^/name/([^/]+)/([^/]+)/edback$|
     *  ^/article/([^/]+)/([^/]+)$|
     *  ^/nice-articles/([^/]+)/([^/]+)$
     *
     * This is done so we can match all routes using only one
     * regex matching call.
     *--------------------------------------------------
     * TODO: combined regex pattern need only to be built one time
     * TODO: once all routes is defined. We can save few loops
     *---------------------------------------------------*)
    function TCombineRegexRouteList.combineRegexRoutes() : string;
    var indx, totalRoutes : integer;
    begin
        //if we get here it is safe to assume that
        //totalRoutes > 0
        result := '';
        totalRoutes := count();
        for indx := 0 to totalRoutes-2 do
        begin
            result := result + '^' + keyOfIndex(indx) + '$|';
        end;
        result := result + '^' + keyOfIndex(totalRoutes-1) + '$';
        writeln(result);
    end;

    (*------------------------------------------------
     * count number of route patterns and its sub group
     *------------------------------------------------
     * @param startIndx start index to look
     * @param startIndx start index to look
     * @return number ot route patterns ant its subgroup
     *-------------------------------------------------
     * For example, if we have following registered route patterns
     *  (0) /name/([^/]+)/([^/]+)/edback/([^/]+)
     *  (1) /article/([^/]+)/([^/]+)
     *  (2) /nice-articles/([^/]+)/([^/]+)
     *
     *  and input of startIndex = 0 and endIndex=1
     *
     *  at iteration, i=0
     *  result = 4 (1 for first route pattern + 4 for ([^/]+) groups)
     *  at iteration, i=1
     *  result = 7 (4 + 1 for second route pattern + 2 for ([^/]+) groups)
     *---------------------------------------------------*)
    function TCombineRegexRouteList.findRouteByMatchIndex(
        const matchIndex : integer
    ) : PRouteRec;
    var routeRec :PRouteRec;
        i, totalPattern, totalRoutes : integer;
    begin
        result := nil;
        totalPattern := 0;
        totalRoutes := hashesList.count();
        for i := 0 to totalRoutes-1 do
        begin
            routeRec := hashesList.get(i);
            if ((matchIndex-1 = 0) and (i=0)) then
            begin
                //match first route,
                //no need to do number of placeholder calculation
                result := routeRec;
                exit;
            end else
            begin
                totalPattern := totalPattern + 1 + length(routeRec^.placeHolders);
                if (matchIndex = totalPattern-1) then
                begin
                    result := routeRec;
                    exit;
                end;
            end;
        end;
    end;

    (*------------------------------------------------
     * find matched route based on regex match result
     *------------------------------------------------
     * @param matchResult
     * @return instance of PRouteDataRec if found or nil
     *         otherwise
     *-------------------------------------------------
     * For example, if we have following uri
     *   /name/juhara/nice/edback
     * and following registered route patterns
     *  (0) /article/([^/]+)/([^/]+)
     *  (1) /nice-articles/([^/]+)/([^/]+)
     *  (2) /name/([^/]+)/([^/]+)/edback
     *
     * with combined regex pattern, a match will cause
     * matchResult contain following values:
     *
     * matchResult.matched=true
     * matchResult.matches[0][0]='/name/juhara/nice/edback'
     *
     * ===== route pattern /article/([^/]+)/([^/]+), no match=====
     * matchResult.matches[0][1]=''
     * ==== first group of route pattern /article/([^/]+)/([^/]+), no match ===
     * matchResult.matches[0][2]=''
     * ====second group of route pattern /article/([^/]+)/([^/]+), no match====
     * matchResult.matches[0][3]=''
     * ====route pattern /nice-articles/([^/]+)/([^/]+), no match===
     * matchResult.matches[0][4]=''
     * ===first group of route pattern /nice-articles/([^/]+)/([^/]+), no match==
     * matchResult.matches[0][5]=''
     * ===second group of route pattern /nice-articles/([^/]+)/([^/]+), no match==
     * matchResult.matches[0][6]=''
     * ===== route pattern /name/([^/]+)/([^/]+)/edback, match=====
     * matchResult.matches[0][7]='/name/juhara/nice/edback'
     * ===== first group of route pattern /name/([^/]+)/([^/]+)/edback, match=====
     * matchResult.matches[0][8]='juhara'
     * ===== second group of route pattern /name/([^/]+)/([^/]+)/edback, match=====
     * matchResult.matches[0][9]='nice'
     *
     * this method job is to find the first non empty matches
     * for matchResult.matches[0][n] where n>0
     *---------------------------------------------------*)
    function TCombineRegexRouteList.findMatchedRoute(const matchResult : TRegexMatchResult) : PRouteRec;
    var i, j, len, len2 : integer;
    begin
        result := nil;
        len := length(matchResult.matches);
        for i:=0 to len-1 do
        begin
            len2 := length(matchResult.matches[i]);
            for j:=0 to len2-1 do
            begin
                if ((j>0) and (length(matchResult.matches[i][j]) > 0)) then
                begin
                    result := findRouteByMatchIndex(j);
                    result^.placeholders := getPlaceholderValuesFromUri(
                        matchResult,
                        result^.placeHolders
                    );
                    exit;
                end
            end;
        end;
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
     *  (3) /nice-articles/([^/]+)/([^/]+)
     *
     * (i) We will combine all registered route patterns in list into one
     * string regex in form, so we can match all routes using only one
     * regex matching call.
     *
     *  ^(/name/([^/]+)/([^/]+)/edback)$|
     *  ^(/article/([^/]+)/([^/]+)$|
     *  ^(/nice-articles/([^/]+)/([^/]+)$
     *
     * (ii) Based on matched group (the second non empty group),
     * we can get index to the list of routes list.
     * (iii) parse capture group based on its placeholder to get value
     * (iv) return route data with its placeholder data
     *---------------------------------------------------*)
    function TCombineRegexRouteList.findRoute(const requestUri : string) : PRouteRec;
    var combinedRegex : string;
        matches : TRegexMatchResult;
    begin
        result := nil;
        combinedRegex := combineRegexRoutes();
        matches := regex.match(combinedRegex, requestUri);
        if (matches.matched) then
        begin
            result := findMatchedRoute(matches);
        end;
    end;

    (*!-----------------------------------------
     * match request uri with route list and return
     * its associated data
     *------------------------------------------*)
    function TCombineRegexRouteList.match(const requestUri : shortstring) : pointer;
    begin
        result := nil;
        if (count() <> 0) then
        begin
            result := findRoute(requestUri);
        end;
    end;

    (*------------------------------------------------
     * find data using its key
     *---------------------------------------------------*)
    function TCombineRegexRouteList.find(const key : shortstring) : pointer;
    begin
        result := hashesList.find(translateRouteName(key));
    end;

    function TCombineRegexRouteList.count() : integer;
    begin
        result := hashesList.count();
    end;

    function TCombineRegexRouteList.get(const indx : integer) : pointer;
    begin
        result := hashesList.get(indx);
    end;

    procedure TCombineRegexRouteList.delete(const indx : integer);
    begin
        hashesList.delete(indx);
    end;

    function TCombineRegexRouteList.keyOfIndex(const indx : integer) : shortstring;
    begin
        result := hashesList.keyOfIndex(indx);
    end;
end.

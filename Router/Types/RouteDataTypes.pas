unit RouteDataTypes;

interface

{$H+}

type
    TSimplePlaceholder = record
        phName : string;
        phValue : string;
    end;
    TArrayOfSimplePlaceholders = array of TSimplePlaceholder;

    TRouteDataRec = record
        placeholders: TArrayOfSimplePlaceholders;
        routeData : pointer;
    end;
    PRouteDataRec = ^TRouteDataRec;

implementation



end.
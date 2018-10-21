unit PlaceholderTypes;

interface

{$H+}

type

    TPlaceholder = record
        phName : string;
        phValue : string;
        phFormatRegex : string;
    end;
    TArrayOfPlaceholders = array of TPlaceholder;


implementation



end.
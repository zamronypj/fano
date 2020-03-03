{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit UrlencodedParserImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    Classes,
    ListIntf,
    DependencyContainerIntf,
    FormUrlencodedParserIntf,
    EnvironmentIntf;

type

    (*!----------------------------------------------
     * basic implementation having capability as
     * parse query string or application/x-www-form-urlencoded request
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TUrlencodedParser = class abstract (TInterfacedObject, IFormUrlencodedParser)
    protected
        procedure initParamsFromString(
            const data : string;
            const body : IList;
            const separatorChar : char
        );
    public

        (*!----------------------------------------
         * Read query string or body data and parse
         * it and store parsed data in body request parameter
         *------------------------------------------
         * @param postData POST data from web server
         * @param body instance of IList that will store
         *             parsed body parameter
         * @return current instance
         *------------------------------------------*)
        function parse(
            const contentType : string;
            const postData : string;
            const body : IList;
            out uploadedFiles : IUploadedFileCollectionWriter
        ) : IMultipartFormDataParser; virtual; abstract;
    end;

implementation

uses

    sysutils,
    EInvalidRequestImpl;

    procedure TUrlencodedParser.initParamsFromString(
        const data : string;
        const body : IList;
        const separatorChar : char
    );
    var arrOfQryStr, keyvalue : TStringArray;
        i, len, lenKeyValue : integer;
        param : PKeyValue;
    begin
        arrOfQryStr := data.split([separatorChar]);
        len := length(arrOfQryStr);
        for i:= 0 to len-1 do
        begin
            keyvalue := arrOfQryStr[i].split('=');
            lenKeyValue := length(keyvalue);
            if (lenKeyValue > 0) then
            begin
                new(param);
                param^.key := trim(keyvalue[0]);
                if (lenKeyValue = 2) then
                begin
                    param^.value := (keyvalue[1]).urlDecode();
                end else
                begin
                    //if we get here then we have query parameter with empty data
                    //such as 'id='
                    param^.value := '';
                end;
                body.add(param^.key, param);
            end;
        end;
    end;

end.

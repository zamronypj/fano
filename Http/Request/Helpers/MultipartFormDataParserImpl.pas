{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit MultipartFormDataParserImpl;

interface

{$MODE OBJFPC}

uses

    MultipartFormDataParserIntf;
type

    (*!----------------------------------------------
     * basic implementation having capability as
     * parse multipart/form-data request
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TMultipartFormDataParser = class(TInterfacedObject, IMultipartFormDataParser)
    public
        function parse() : IMultipartFormDataParser;
    end;

implementation

    function TMultipartFormDataParser.parse() : IMultipartFormDataParser;
    begin

    end;
end.

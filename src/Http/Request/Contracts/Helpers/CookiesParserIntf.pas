{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit CookiesParserIntf;

interface

{$MODE OBJFPC}
{$H+}

uses

    FormUrlencodedParserIntf;

type

    (*!----------------------------------------------
     * interface for any class having capability as
     * parse raw cookies data into parsed cookies data
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    ICookiesParser = interface(IFormUrlencodedParser)
        ['{514FDC90-CEC9-45FB-8B74-8714D537DBFE}']
    end;

implementation
end.

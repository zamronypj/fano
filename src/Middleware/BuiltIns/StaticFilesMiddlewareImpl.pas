{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2022 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit StaticFilesMiddlewareImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    BaseStaticFilesMiddlewareImpl;

type

    (*!------------------------------------------------
     * middleware class that serves static files from
     * a base directory.
     *-------------------------------------------------
     * Content type of response will be determined
     * using file extension that is stored in fMimeTypes
     * if not set then 'application/octet-stream' is assumed
     *-------------------------------------------------
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TStaticFilesMiddleware = class(TBaseStaticFilesMiddleware)
    protected
        (*!-------------------------------------------
         * clean filepath avoid serve hidden dot files in unix
         *--------------------------------------------
         * @param filePath original file path
         * @return new cleaned file path
         *--------------------------------------------*)
        function clean(const filePath: string) : string; override;
    public
    end;

implementation

uses

    SysUtils;


    (*!-------------------------------------------
     * clean filepath avoid serve hidden dot files in unix
     *--------------------------------------------
     * @param filePath original file path
     * @return new cleaned file path
     *--------------------------------------------*)
    function TStaticFilesMiddleware.clean(const filePath: string) : string;
    begin
        // for example if filePath contain '/.htaccess' we replace it so
        // filePath become '/htaccess'
        result := stringReplace(filePath, '/.', '/', [rfReplaceAll]);
        // just paranoia handle .. too
        result := stringReplace(result, '..', '', [rfReplaceAll]);
    end;

end.

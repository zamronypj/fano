{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit MhdSvrConfigTypes;

interface

{$MODE OBJFPC}
{$H+}

type

    TMhdSvrConfig = record
        host : string;
        port : word;
        documentRoot : string;
        serverName : string;
        serverSoftware : string;
        serverSignature : string;
        serverAdmin : string;
        timeout : longword;
    end;

    function initMhdSvrConfig() : TMhdSvrConfig;
implementation

uses

    SysUtils;

    function initMhdSvrConfig() : TMhdSvrConfig;
    begin
        with result do
        begin
            host := '127.0.0.1';
            port := 80;
            documentRoot := getCurrentDir() + '/public';
            serverName := 'web.fano';
            serverSoftware := 'Fano Framework Web App';
            serverSignature := 'Fano Framework Web App';
            serverAdmin := 'admin@web.fano';
            timeout := 120;
        end;
    end;
end.

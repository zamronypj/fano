{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2020 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit IndyTypes;

interface

{$MODE OBJFPC}
{$H+}


type

    TSmtpConfig = record
        host : string;
        port : word;
        username : string;
        password : string;
        timeout : integer;
        useTls : boolean;
    end;

implementation

end.

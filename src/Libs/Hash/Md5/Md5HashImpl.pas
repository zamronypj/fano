{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit Md5HashImpl;

interface

{$MODE OBJFPC}
{$H+}

type

    (*!------------------------------------------------
     * interface for any class having capability to
     * generate hashed string
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TMd5Hash = class(TInterfacedObject, IHash)
    public

        (*!------------------------------------------------
         * hash string
         *-----------------------------------------------
         * @param originalStr original string
         * @return hashed string
         *-----------------------------------------------*)
        function hash(const originalStr : string) : string;

    end;

implementation

uses

    md5;

    (*!------------------------------------------------
     * hash string
     *-----------------------------------------------
     * @param originalStr original string
     * @return hashed string
     *-----------------------------------------------*)
    function TMd5Hash.hash(const originalStr : string) : string;
    begin
        result := MD5Print(MD5String(originalStr));
    end;
end.

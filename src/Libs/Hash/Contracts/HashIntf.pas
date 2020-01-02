{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit HashIntf;

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
    IHash = interface
        ['{9B4CC558-D26E-4BA2-9F26-CB0F2A14EF15}']

        (*!------------------------------------------------
         * hash string
         *-----------------------------------------------
         * @param originalStr original string
         * @return hashed string
         *-----------------------------------------------*)
        function hash(const originalStr : string) : string;

    end;

implementation

end.

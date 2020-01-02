{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit CacheItemIntf;

interface

{$MODE OBJFPC}
{$H+}

uses

    SerializeableIntf;

type

    (*!------------------------------------------------
     * interface for any class having capability to be
     * stored in cache
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    ICacheItem = interface
        ['{1D7FD80D-6A51-48CE-8C47-B6E4CF6B9118}']

        (*!------------------------------------------------
         * get time to live value in seconds
         *-----------------------------------------------
         * @return time to live
         *-----------------------------------------------*)
        function ttl() : integer;

        (*!------------------------------------------------
         * get actual data
         *-----------------------------------------------
         * @return data
         *-----------------------------------------------*)
        function data() : ISerializeable;
    end;

implementation

end.

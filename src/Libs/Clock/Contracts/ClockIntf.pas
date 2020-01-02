{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ClockIntf;

interface

{$MODE OBJFPC}
{$H+}

type

    (*!------------------------------------------------
     * interface for any class having capability to read
     * current date time
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IClock = interface
        ['{15114EB7-7F27-463A-9B1C-A88911651D7D}']

        (*!------------------------------------------------
         * get current datetime
         *-----------------------------------------------
         * @return current date time
         *-----------------------------------------------*)
        function getCurrentTime() : TDateTime;
    end;

implementation

end.

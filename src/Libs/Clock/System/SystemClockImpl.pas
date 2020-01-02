{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit SystemClockImpl;

interface

{$MODE OBJFPC}
{$H+}

type

    (*!------------------------------------------------
     * class having capability to read system
     * current date time
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TSystemClock = class(TInterfacedObject, IClock)
    public

        (*!------------------------------------------------
         * get current datetime
         *-----------------------------------------------
         * @return current date time
         *-----------------------------------------------*)
        function getCurrentTime() : TDateTime;
    end;

implementation

uses

    SysUtils;

    (*!------------------------------------------------
     * get current datetime
     *-----------------------------------------------
     * @return current date time
     *-----------------------------------------------*)
    function TSystemClock.getCurrentTime() : TDateTime;
    begin
        result := Now;
    end;

end.

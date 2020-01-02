{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FixedClockImpl;

interface

{$MODE OBJFPC}
{$H+}

type

    (*!------------------------------------------------
     * class having capability to read fixed
     * current date time
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFixedClock = class(TInterfacedObject, IClock)
    private
        fCurrDateTime : TDateTime;
    public
        constructor create(currDateTime : TDateTime);

        (*!------------------------------------------------
         * get current datetime
         *-----------------------------------------------
         * @return current date time
         *-----------------------------------------------*)
        function getCurrentTime() : TDateTime;
    end;

implementation

    constructor TFixedClock.create(currDateTime : TDateTime);
    begin
        fCurrDateTime := currDateTime;
    end;

    (*!------------------------------------------------
     * get current datetime
     *-----------------------------------------------
     * @return current date time
     *-----------------------------------------------*)
    function TFixedClock.getCurrentTime() : TDateTime;
    begin
        result := fCurrDateTime;
    end;

end.

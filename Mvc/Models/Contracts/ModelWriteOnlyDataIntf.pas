{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ModelWriteOnlyDataIntf;

interface

{$MODE OBJFPC}
{$H+}

type

    (*!------------------------------------------------
     * interface that store model data
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IModelWriteOnlyData = interface
        ['{6CB5843D-56E3-4012-AB5B-7A354A0EE5D3}']

        function writeString(const key : string; const value : string) : IModelWriteOnlyData;
        function writeInteger(const key : string; const value : integer) : IModelWriteOnlyData;
    end;

implementation

end.

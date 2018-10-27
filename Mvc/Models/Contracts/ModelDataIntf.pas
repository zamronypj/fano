{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit ModelDataIntf;

interface

{$MODE OBJFPC}
{$H+}

type

    (*!------------------------------------------------
     * interface that store model data
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IModelData = interface
        ['{DCC3EA21-DC74-46A2-BF54-54621B736E49}']
        function readString(const key : string) : string;
        function writeString(const key : string; const value : string) : IModelData;
        function readInteger(const key : string) : integer;
        function writeInteger(const key : string; const value : integer) : IModelData;
    end;

implementation



end.

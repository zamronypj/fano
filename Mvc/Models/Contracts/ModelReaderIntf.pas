{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ModelReaderIntf;

interface

{$MODE OBJFPC}

uses

    ModelDataIntf;

type

    (*!------------------------------------------------
     * interface for model that can retrieve data
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IModelReader = interface
        ['{8066B3EE-A1F6-4971-8545-1BC741333986}']

        (*!----------------------------------------------
         * read data from storage
         *-----------------------------------------------
         * @param params parameter for search/filtering
         * @return model presenter
         *-----------------------------------------------*)
        function read(const params : IModelData = nil) : IModelData;
    end;

implementation

end.

{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ModelPresenterIntf;

interface

{$MODE OBJFPC}

uses

    ModelPresenterIntf;

type

    (*!------------------------------------------------
     * interface for class that has presenter
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IModelPresenterAware = interface
        ['{DA04DD04-101E-4AAC-AAD7-9E7EB0A88730}']

        (*!----------------------------------------------
         * get presenter
         *-----------------------------------------------
         * @return model presenter
         *-----------------------------------------------*)
        function presenter() : IModelPresenter;
    end;

implementation

end.

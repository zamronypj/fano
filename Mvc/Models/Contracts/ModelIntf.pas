{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ModelIntf;

interface

{$MODE OBJFPC}

uses

    ModelDataIntf;

type

    (*!------------------------------------------------
     * interface for model
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IModel = interface
        ['{A8601E0D-0D5F-4580-BAED-55C598AEBDEF}']
        function get(const params : IModelData) : IModelData;
        function save(
            const params : IModelData;
            const data : IModelData;
        ) : IModel;
    end;

implementation

end.

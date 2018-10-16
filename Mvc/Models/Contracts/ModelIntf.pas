{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}

unit ModelIntf;

interface

uses

    ModelDataIntf;

type

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

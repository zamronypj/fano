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
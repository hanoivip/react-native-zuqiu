local Node = class(nil, "Node")

function Node:ctor(config)
    config = config or { }
    for k, v in pairs(config) do
        self[k] = v
    end
end

-- callbacks called in run function
function Node:run() end

-- call by parent
function Node:_createInstance() end
function Node:_stopRunning(instance) end
function Node:_run(object, instance) end

return Node

if jit then jit.off(true, true) end

local Node = import("./Node")

local Condition = class(Node, "Condition")

function Condition:_createInstance()
    return { }
end

function Condition:_run(object, instance)
    return self:run(object)
end

return Condition

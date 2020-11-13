if jit then jit.off(true, true) end

local Node = import("./Node")

local Task = class(Node, "Task")

function Task:_createInstance()
    return { _isRunning = false }
end

function Task:_stopRunning(instance)
    instance._isRunning = false
end

function Task:_run(object, instance)
    local result = self:run(object, instance._isRunning)
    instance._isRunning = result == "running"

    return result
end

return Task

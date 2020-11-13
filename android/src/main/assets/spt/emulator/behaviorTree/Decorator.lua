if jit then jit.off(true, true) end

local Node = import("./Node")

local Decorator = class(Node, "Decorator")

function Decorator:_createInstance()
    return { _isRunning = false, child = self.child:_createInstance() }
end

function Decorator:_stopRunning(instance)
    instance._isRunning = false
    self.child:_stopRunning(instance.child)
end

if jit then jit.on(Decorator._stopRunning, true) end

function Decorator:_run(object, instance)
    local childResult = self.child:_run(object, instance.child)

    instance._isRunning = childResult == "running"

    return childResult
end

return Decorator

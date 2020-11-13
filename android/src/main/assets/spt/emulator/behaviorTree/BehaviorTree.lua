if jit then jit.off(true, true) end

local Node = import("./Node")

local BehaviorTree = class(Node, "BehaviorTree")

BehaviorTree.Task = import("./Task")
BehaviorTree.Condition = import("./Condition")
BehaviorTree.Priority = import("./Priority")
BehaviorTree.Sequence = import("./Sequence")
BehaviorTree.AlwaysSuccessDecorator = import("./AlwaysSuccessDecorator")

function BehaviorTree:createInstance()
    return self.tree:_createInstance()
end

function BehaviorTree:run(object, instance)
    local result = self.tree:_run(object, instance)
    instance._isRunning = result == "running"

    return result
end

function BehaviorTree:stopRunning(instance)
    self.tree:_stopRunning(instance)
end

if jit then jit.on(BehaviorTree.stopRunning, true) end

return BehaviorTree

local Node = import("./Node")

if jit then jit.off(true, true) end

local Sequence = class(Node, "Sequence")

function Sequence:_createInstance()
    local instance = { _isRunning = false, _runningChildId = 0, children = {} }
    for i = 1, #self.children do
        instance.children[i] = self.children[i]:_createInstance()
    end
    return instance
end

function Sequence:_stopRunning(instance)
    instance._isRunning = false
    instance._runningChildId = 0
    for i = 1, #self.children do
        self.children[i]:_stopRunning(instance.children[i])
    end
end

if jit then jit.on(Sequence._stopRunning, true) end

function Sequence:_run(object, instance)
    local startChildId = 1

    if instance._isRunning then
        local runningChild = self.children[instance._runningChildId]
        local runningChildResult = runningChild:_run(object, instance.children[instance._runningChildId])

        if runningChildResult == "running" then
            instance._isRunning = true
            return "running"
        elseif runningChildResult == "fail" then
            instance._isRunning = false
            instance._runningChildId = 0
            return "fail"
        end
        
        startChildId = instance._runningChildId + 1
    end

    for i = startChildId, #self.children do
        local childResult = self.children[i]:_run(object, instance.children[i])
        if childResult == "running" then
            instance._isRunning = true
            instance._runningChildId = i
            return "running"
        elseif childResult == "fail" then
            instance._isRunning = false
            instance._runningChildId = 0
            return "fail"
        end
    end

    instance._isRunning = false
    instance._runningChildId = 0
    return "success"
end

return Sequence

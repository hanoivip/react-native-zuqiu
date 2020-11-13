if jit then jit.off(true, true) end

local Node = import("./Node")

local Priority = class(Node, "Priority")

function Priority:_createInstance()
    local instance = { _isRunning = false, _runningChildId = 0, children = {} }
    for i = 1, #self.children do
        instance.children[i] = self.children[i]:_createInstance()
    end
    return instance
end

function Priority:_stopRunning(instance)
    instance._isRunning = false
    instance._runningChildId = 0
    for i = 1, #self.children do
        self.children[i]:_stopRunning(instance.children[i])
    end
end

function Priority:_run(object, instance)
    local startChildId = 1

    if instance._isRunning then
        local runningChild = self.children[instance._runningChildId]
        local runningChildResult = runningChild:_run(object, instance.children[instance._runningChildId])

        if runningChildResult == "running" then
            instance._isRunning = true
            return "running"
        elseif runningChildResult == "success" then
            instance._isRunning = false
            instance._runningChildId = 0
            return "success"
        end

        startChildId = instance._runningChildId + 1
    end

    for i = startChildId, #self.children do
        local childResult = self.children[i]:_run(object, instance.children[i])
        if childResult == "running" then
            instance._isRunning = true
            instance._runningChildId = i
            return "running"
        elseif childResult == "success" then
            instance._isRunning = false
            instance._runningChildId = 0
            return "success"
        end
    end

    instance._isRunning = false
    instance._runningChildId = 0
    return "fail"
end

return Priority

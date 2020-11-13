event = {}

local eventMt = {}
eventMt.__index = eventMt

function event.new()
    return setmetatable({ handlers = {} }, eventMt)
end

local function isHandlerCallable(callable)
    if type(callable) == "table" then
        if type(getmetatable(callable)["__call"]) == "function" then
            return true
        end
    elseif type(callable) == "function" then
        return true
    elseif type(callable) == "thread" then
        if coroutine.status(callable) ~= "dead" then
            return true
        end
    end
    return false
end

function eventMt:addHandler(handler, target)
    assert(isHandlerCallable(handler))
    if self:hasHandler(handler, target) then return end

    table.insert(self.handlers, { callable = handler, target = target })
end

function eventMt:removeHandler(handler, target)
    local exists, index = self:hasHandler(handler, target)
    if exists then
        table.remove(self.handlers, index)
    end
end

function eventMt:removeAllHandlers()
    self.handlers = {}
end

function eventMt:getHandlerCount()
    return #self.handlers
end

function eventMt:hasHandler(handlerToFind, target)
    for i, handler in ipairs(self.handlers) do
        if handler.callable == handlerToFind and handler.target == target then
            return true, i
        end
    end

    return false, nil
end

function eventMt:trigger(...)
    local needRemoval = false
    for i, handler in ipairs(self.handlers) do
        if type(handler.callable) == "thread" then
            if handler.target == nil then
                coroutine.resume(handler.callable, ...)
            else
                coroutine.resume(handler.callable, handler.target, ...)
            end
            if coroutine.status(handler.callable) == "dead" then
                needRemoval = true
            end
        else
            if handler.target == nil then
                handler.callable(...)
            else
                handler.callable(handler.target, ...)
            end
        end
    end

    if needRemoval then
        local index, len = 1, #self.handlers
        while index <= len do
            if coroutine.status(self.handlers[index].callable) == "dead" then
                table.remove(self.handlers, index)
                len = len - 1
            else
                index = index + 1
            end
        end
    end
end

return event

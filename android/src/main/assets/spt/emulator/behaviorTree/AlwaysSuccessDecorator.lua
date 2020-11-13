if jit then jit.off(true, true) end

local Decorator = import("./Decorator")

local AlwaysSuccessDecorator = class(Decorator, "AlwaysSuccessDecorator")

function AlwaysSuccessDecorator:_run(object, instance)
    local result = AlwaysSuccessDecorator.super._run(self, object, instance)
    return result == "running" and "running" or "success"
end

return AlwaysSuccessDecorator

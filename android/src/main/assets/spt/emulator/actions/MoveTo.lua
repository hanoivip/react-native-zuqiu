local Action = import("./Action")
local vector2 = import("../libs/vector")

local MoveTo = class(Action)

function MoveTo:ctor()
    self.name = "MoveTo"
    self.duration = 0.1
    self.targetPosition = vector2.clone(vector2.zero)
end

return MoveTo

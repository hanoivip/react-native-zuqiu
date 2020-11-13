local Action = import("./Action")
local vector2 = import("../libs/vector")

local MoveDefend = class(Action)

function MoveDefend:ctor()
    self.name = "MoveDefend"
    self.targetPosition = vector2.clone(vector2.zero)
end

return MoveDefend

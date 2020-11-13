local Action = import("./Action")
local vector2 = import("../libs/vector")

local Catch = class(Action)

function Catch:ctor()
    self.name = "Catch"
end

return Catch

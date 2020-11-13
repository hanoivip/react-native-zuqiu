local Action = import("./Action")
local vector2 = import("../libs/vector")

local Pass = class(Action)

function Pass:ctor()
    self.name = "Pass"
    self.targetPosition = vector2.clone(vector2.zero)
    self.targetAthlete = nil
    self.type = "Ground"
    self.isLeadPass = nil
    self.duration = 0
    self.isIntercepted = nil
    self.interceptPosition = nil
    self.interceptAthlete = nil
    self.interceptDuration = nil
    self.passBodyPartType = nil
end

return Pass

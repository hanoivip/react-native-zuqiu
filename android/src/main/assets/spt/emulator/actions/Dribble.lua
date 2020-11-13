local Action = import("./Action")
local vector2 = import("../libs/vector")

local Dribble = class(Action)

function Dribble:ctor()
    self.name = "Dribble"
    self.direction = vector2.clone(vector2.forward)
    self.isStolen = false
    self.stealPosition = nil
    self.stealAthlete = nil
    self.stealDuration = nil
    self.isFouled = false
    self.foulPosition = nil
    self.foulAthlete = nil
    self.foulDuration = nil
    self.animation = nil
    self.animationType = nil
    self.sprintAnimation = nil
end

return Dribble

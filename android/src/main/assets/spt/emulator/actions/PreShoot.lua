local Action = import("./Action")
local vector2 = import("../libs/vector")

local PreShoot = class(Action)

function PreShoot:ctor()
    self.name = "PreShoot"
    self.targetPosition = vector2.clone(vector2.zero)
    self.goalProbability = 0
    self.isGoal = false
    self.isSaved = false
    self.savePosition = nil
    self.saver = nil
    self.saveTime = nil
    self.isBounced = false
    self.isShootWide = false
    self.isShootHigh = false
end

function PreShoot:toString()
    return string.format("[PreShoot Action] TargetPosition=%s, GoalProb=%s, IsGoal=%s, IsSaved=%s, IsBounced=%s, IsShootWide=%s, IsShootHigh=%s, SaveTime=%s, SavePos=%s",
        tostring(self.targetPosition),
        tostring(self.goalProbability),
        tostring(self.isGoal),
        tostring(self.isSaved),
        tostring(self.isBounced),
        tostring(self.isShootWide),
        tostring(self.isShootHigh),
        tostring(self.saveTime),
        tostring(self.savePosition))
end

return PreShoot

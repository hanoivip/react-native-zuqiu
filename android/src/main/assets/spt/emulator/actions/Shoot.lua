local Action = import("./Action")
local vector2 = import("../libs/vector")

local Shoot = class(Action)

function Shoot:ctor()
    self.name = "Shoot"
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

    self.reason = nil
    self.skill = nil
    self.shootAnimationType = nil
end

function Shoot:toString()
    return string.format("[Shoot Action] TargetPosition=%s, GoalProb=%s, IsGoal=%s, IsSaved=%s, IsBounced=%s, IsShootWide=%s, IsShootHigh=%s, SaveTime=%s, SavePos=%s, ShootAnimationType=%s",
        tostring(self.targetPosition),
        tostring(self.goalProbability),
        tostring(self.isGoal),
        tostring(self.isSaved),
        tostring(self.isBounced),
        tostring(self.isShootWide),
        tostring(self.isShootHigh),
        tostring(self.saveTime),
        tostring(self.savePosition),
        tostring(self.shootAnimationType))
end

return Shoot

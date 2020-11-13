local Skill = import("../Skill")
local Poacher = import("./Poacher")

local PoacherEx1 = class(Poacher, "PoacherEx1")
PoacherEx1.id = "A03_1"
PoacherEx1.alias = "偷猎者"

local minAddConfig = 0.363
local maxAddConfig = 0.66
local minSubConfig = 0.12
local maxSubConfig = 0.22
local durationConfig = 15

function PoacherEx1:ctor(level)
    Poacher.ctor(self, level)

    self.ex1AddRatio = Skill.lerpLevel(minAddConfig, maxAddConfig, level)
    self.ex1SubRatio = -Skill.lerpLevel(minSubConfig, maxSubConfig, level)

    self.ex1Buff = {
        skill = self,
        duration = durationConfig,
        removalCondition = function(remainingTime, caster, receiver)
            return math.cmpf(remainingTime, 0) <= 0
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.ex1AddRatio
        end,
    }

    self.ex1Debuff = {
        skill = self,
        duration = durationConfig,
        removalCondition = function(remainingTime, caster, receiver)
            return math.cmpf(remainingTime, 0) <= 0
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.ex1SubRatio
        end,
    }
end

return PoacherEx1

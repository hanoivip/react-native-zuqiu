local Skill = import("../Skill")
local FiercelyDogfight = import("./FiercelyDogfight")
local GamesmanshipEx1 = import("./GamesmanshipEx1")

local FiercelyDogfightEx1 = class(GamesmanshipEx1, "FiercelyDogfightEx1")
FiercelyDogfightEx1.id = "A02_A_1"
FiercelyDogfightEx1.alias = "凶悍缠斗"

local minAddConfig = 0.25
local maxAddConfig = 0.25
local minProbabilityConfig = 1
local maxProbabilityConfig = 1

function FiercelyDogfightEx1:ctor(level)
    if FiercelyDogfight.initConfig then
        FiercelyDogfight:initConfig(self)
    end
    GamesmanshipEx1.ctor(self, level)
    self.exa1Probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
    self.exa1AddRatio = Skill.lerpLevel(minAddConfig, maxAddConfig, level)
    self.exa1Buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return false
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.exa1AddRatio
        end,
        persistent = true
    }
end

return FiercelyDogfightEx1
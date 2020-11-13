local Skill = import("../Skill")

local Poacher = class(Skill, "Poacher")
Poacher.id = "A03"
Poacher.alias = "偷猎者"

local cooldownConfig = 0
local minProbabilityConfig = 1
local maxProbabilityConfig = 1
local minAbilitiesInterceptSumMultiply = 0.33
local maxAbilitiesInterceptSumMultiply = 3.3
local minAbilitiesStealSumMultiply = 0.33
local maxAbilitiesStealSumMultiply = 3.3

function Poacher:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.cooldown = cooldownConfig
    self.remainingCooldown = 0
    self.probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
    self.abilitiesInterceptSumMultiply = Skill.lerpLevel(minAbilitiesInterceptSumMultiply, maxAbilitiesInterceptSumMultiply, level)
    self.abilitiesStealSumMultiply = Skill.lerpLevel(minAbilitiesStealSumMultiply, maxAbilitiesStealSumMultiply, level)

    self.buff = {
        skill = self,
        remark = "base",
        removalCondition = function(remainingTime, caster, receiver)
            return true
        end,
        abilitiesModifier = function(abilities, caster, receiver)
            abilities.intercept = abilities.intercept + receiver.initAbilities.intercept * self.abilitiesInterceptSumMultiply
            abilities.steal = abilities.steal + receiver.initAbilities.steal * self.abilitiesStealSumMultiply
        end,
    }
end

return Poacher

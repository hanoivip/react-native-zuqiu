local Skill = import("../Skill")

local CathexisEx1 = class(Skill, "CathexisEx1")
CathexisEx1.id = "Z07_1"
CathexisEx1.alias = "全神贯注"

local cooldownConfig = 0
local minProbabilityConfig = 0.15
local maxProbabilityConfig = 0.15
local minAddConfig = 0.4
local maxAddConfig = 0.4

function CathexisEx1:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.cooldown = cooldownConfig
    self.remainingCooldown = 0
    self.probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
    self.addRatio = Skill.lerpLevel(minAddConfig, maxAddConfig, level)

    self.buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return false
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio
        end,
        persistent = true
    }
end

return CathexisEx1

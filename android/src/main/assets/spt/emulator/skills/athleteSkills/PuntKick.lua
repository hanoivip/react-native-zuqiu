local Skill = import("../Skill")

local PuntKick = class(Skill, "PuntKick")
PuntKick.id = "E09"
PuntKick.alias = "大脚开球"

local cooldownConfig = 0
local minProbabilityConfig = 1
local maxProbabilityConfig = 1
local minLaunchingConfig = 0.55
local maxLaunchingConfig = 5.5

function PuntKick:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.cooldown = cooldownConfig
    self.remainingCooldown = 0
    self.probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)

    self.buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return not receiver:hasBall()
        end,
        abilitiesModifier = function(abilities, caster)
            abilities.pass = abilities.pass + caster.initAbilities.launching * Skill.lerpLevel(minLaunchingConfig, maxLaunchingConfig, level)
        end
    }
end

return PuntKick
local Skill = import("../Skill")

local Diving = class(Skill, "Diving")
Diving.id = "B02"
Diving.alias = "跳水"

local cooldownConfig = 0
local minProbabilityConfig = 0.7
local maxProbabilityConfig = 0.7
local minAddDribbleConfig = 0.55
local maxAddDribbleConfig = 5.5

function Diving:ctor(level)
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
            return true
        end,
        abilitiesModifier = function(abilities, caster, receiver)
            abilities.dribble = abilities.dribble + receiver.initAbilities.dribble * Skill.lerpLevel(minAddDribbleConfig, maxAddDribbleConfig, level)
        end
    }
end

return Diving

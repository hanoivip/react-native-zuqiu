local Skill = import("../Skill")

local TheSoulOfTheMatador = class(Skill, "TheSoulOfTheMatador")
TheSoulOfTheMatador.id = "LR_DDEGEA2"
TheSoulOfTheMatador.alias = "斗牛士之魂"

local durationConfig = 30
local minProbabilityConfig = 1
local maxProbabilityConfig = 1
local minAddRatio = 0.15
local maxAddRatio = 0.15

function TheSoulOfTheMatador:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.remainingCooldown = 0
    self.probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
    self.subRatio = -Skill.lerpLevel(minAddRatio, maxAddRatio, level)

    self.debuff = {
        skill = self,
        duration = durationConfig,
        removalCondition = function(remainingTime, caster, receiver)
            return math.cmpf(remainingTime, 0) <= 0
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.subRatio
        end,
    }
end

return TheSoulOfTheMatador

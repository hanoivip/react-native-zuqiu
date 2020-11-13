local Skill = import("../Skill")

local CorePlayMaker = class(Skill, "CorePlayMaker")
CorePlayMaker.id = "C04"
CorePlayMaker.alias = "组织核心"

CorePlayMaker.minAbilityConfig = 0.55
CorePlayMaker.maxAbilityConfig = 5.5

function CorePlayMaker:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.remainingCooldown = 0

    self.buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return not receiver:hasBall()
        end,
        abilitiesModifier = function(abilities, caster, receiver)
            abilities.pass = abilities.pass + caster.initAbilities.pass * Skill.lerpLevel(self.minAbilityConfig, self.maxAbilityConfig, level)
        end,
    }
end

return CorePlayMaker

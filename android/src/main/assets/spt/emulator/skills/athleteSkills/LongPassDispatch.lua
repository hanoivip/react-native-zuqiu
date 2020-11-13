local Skill = import("../Skill")

local LongPassDispatch = class(Skill, "LongPassDispatch")
LongPassDispatch.id = "C05"
LongPassDispatch.alias = "长传转移"

-- 传球人加成
LongPassDispatch.minAbilityConfig = 0.55
LongPassDispatch.maxAbilityConfig = 5.5
-- 接球人加成
LongPassDispatch.minAddRatioConfig = 0.22
LongPassDispatch.maxAddRatioConfig = 2.22

function LongPassDispatch:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.remainingCooldown = 0
    self.extraAddRatio = Skill.lerpLevel(LongPassDispatch.minAddRatioConfig, LongPassDispatch.maxAddRatioConfig, level)

    self.buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return not receiver:hasBall()
        end,
        abilitiesModifier = function(abilities, caster, receiver)
            abilities.pass = abilities.pass + caster.initAbilities.pass * Skill.lerpLevel(self.minAbilityConfig, self.maxAbilityConfig, level)
        end,
    }

    self.extraBuff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.team:isDefendRole()
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.extraAddRatio
        end,
    }

end

return LongPassDispatch

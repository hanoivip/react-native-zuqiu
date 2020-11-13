local Skill = import("../Skill")

local Catenaccio = class(Skill, "Catenaccio")
Catenaccio.id = "A07"
Catenaccio.alias = "链式防守"

local minAddConfig = 0.066
local maxAddConfig = 0.66
local minExtraAddConfig = 0.011
local maxExtraAddConfig = 0.11

function Catenaccio:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.remainingCooldown = 0
    self.addRatio = Skill.lerpLevel(minAddConfig, maxAddConfig, level)
    self.extraAddConfig = Skill.lerpLevel(minExtraAddConfig, maxExtraAddConfig, level)

    self.buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.team:isAttackRole()
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio + (caster.team.catenaccioCount - 1) * self.extraAddConfig
        end,
    }
end

return Catenaccio

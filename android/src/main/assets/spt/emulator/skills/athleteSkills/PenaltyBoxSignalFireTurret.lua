local Skill = import("../Skill")

local PenaltyBoxSignalFireTurret = class(Skill, "PenaltyBoxSignalFireTurret")
PenaltyBoxSignalFireTurret.id = "E11"
PenaltyBoxSignalFireTurret.alias = "禁区烽火台"

local minProbabilityConfig = 0.65
local maxProbabilityConfig = 0.65
local minAddConfig = 0.66
local maxAddConfig = 6.6

function PenaltyBoxSignalFireTurret:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.remainingCooldown = 0
    self.level = level
    self.probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
    self.addRatio = Skill.lerpLevel(minAddConfig, maxAddConfig, level)

    self.buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.team:isAttackRole()
        end,
        abilitiesAddRatio = function(caster, receiver)
            local addedValue = caster.initAbilities.commanding * self.addRatio
            return addedValue / receiver.initAbilitiesSum
        end,
    }
end

return PenaltyBoxSignalFireTurret
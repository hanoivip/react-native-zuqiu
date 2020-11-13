local Skill = import("../Skill")

local FightTogether = class(Skill, "FightTogether")
FightTogether.id = "G03"
FightTogether.alias = "众志成城"

local minProbabilityConfig = 0.3
local maxProbabilityConfig = 0.3
local minAddConfig = 0.22
local maxAddConfig = 2.2

function FightTogether:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.remainingCooldown = 0
    self.probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
    self.addRatio = Skill.lerpLevel(minAddConfig, maxAddConfig, level)

    self.buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.team:isAttackRole()
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio
        end,
    }

    self.teamLeaderAddRatio = 0
    self.teamLeaderBuff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.team:isAttackRole()
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.teamLeaderAddRatio
        end,
    }

end

return FightTogether
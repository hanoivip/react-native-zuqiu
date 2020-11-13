local Skill = import("../Skill")
local AIConstants = import("../../AIConstants")

local LeaderMaster = class(Skill, "LeaderMaster")
LeaderMaster.id = "M16"
LeaderMaster.alias = "顺风球高手"

local minAddConfig = 0.08
local maxAddConfig = 8

function LeaderMaster:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.remainingCooldown = 0
    self.addRatio = Skill.lerpLevel(minAddConfig, maxAddConfig, level)

    self.buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.team.scoreState ~= AIConstants.teamScoreState.LEAD
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio
        end,
        persistent = true
    }
end

return LeaderMaster

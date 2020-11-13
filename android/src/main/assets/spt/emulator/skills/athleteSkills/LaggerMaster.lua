local Skill = import("../Skill")
local AIConstants = import("../../AIConstants")

local LaggerMaster = class(Skill, "LaggerMaster")
LaggerMaster.id = "M17"
LaggerMaster.alias = "逆风球高手"

local minAddConfig = 0.13
local maxAddConfig = 13

function LaggerMaster:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.remainingCooldown = 0
    self.addRatio = Skill.lerpLevel(minAddConfig, maxAddConfig, level)

    self.buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.team.scoreState ~= AIConstants.teamScoreState.LAG
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio
        end,
        persistent = true
    }
end

return LaggerMaster

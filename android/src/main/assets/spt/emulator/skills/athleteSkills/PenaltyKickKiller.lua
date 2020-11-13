local Skill = import("../Skill")

local PenaltyKickKiller = class(Skill, "PenaltyKickKiller")
PenaltyKickKiller.id = "E07"
PenaltyKickKiller.alias = "点球杀手"

local minAddComposureConfig = 0.66
local maxAddComposureConfig = 6.6

function PenaltyKickKiller:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.remainingCooldown = 0
    self.addComposureConfig = Skill.lerpLevel(minAddComposureConfig, maxAddComposureConfig, level)

    self.buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.match.ball.owner == nil
        end,
    }
end

return PenaltyKickKiller
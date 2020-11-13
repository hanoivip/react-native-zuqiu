local Skill = import("../Skill")
local vector2 = import("../../libs/vector")

local TightMark = class(Skill, "TightMark")
TightMark.id = "A08"
TightMark.alias = "盯人"

local minAddConfig = 0.55
local maxAddConfig = 5.5

function TightMark:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.remainingCooldown = 0
    self.addConfig = Skill.lerpLevel(minAddConfig, maxAddConfig, level)

    self.buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.team:isDefendRole() or caster.onfieldId == nil
        end,
        abilitiesAddRatio = function(caster, receiver)
            return 0
        end,
    }
end

return TightMark

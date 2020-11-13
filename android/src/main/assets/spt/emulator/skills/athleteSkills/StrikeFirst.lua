local Skill = import("../Skill")

local StrikeFirst = class(Skill, "StrikeFirst")
StrikeFirst.id = "M18"
StrikeFirst.alias = "先发制人"

local minAddConfig = 0.13
local maxAddConfig = 13

function StrikeFirst:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.remainingCooldown = 0
    self.addRatio = Skill.lerpLevel(minAddConfig, maxAddConfig, level)

    self.buff = {
        skill = self,
        remark = "ignoreCannotAddBuffDebuff",
        removalCondition = function(remainingTime, caster, receiver)
            return math.cmpf(receiver.match:getActualDisplayTime(), 30) > 0
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio
        end,
    }
end

function StrikeFirst:enterField(athlete)
    if math.cmpf(athlete.match:getActualDisplayTime(), 30) < 0 then
        athlete:castSkill(StrikeFirst)
        athlete:addBuff(self.buff, athlete)
    end
end

return StrikeFirst

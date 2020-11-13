local Skill = import("../Skill")

local DesperateFight = class(Skill, "DesperateFight")
DesperateFight.id = "M19"
DesperateFight.alias = "殊死一搏"

local minAddConfig = 0.13
local maxAddConfig = 13

function DesperateFight:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.remainingCooldown = 0
    self.addRatio = Skill.lerpLevel(minAddConfig, maxAddConfig, level)

    self.buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return math.cmpf(receiver.match:getActualDisplayTime(), 90) > 0
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio
        end,
    }
end

function DesperateFight:enterField(athlete)
    if math.cmpf(athlete.match:getActualDisplayTime(), 60) > 0 and math.cmpf(athlete.match:getActualDisplayTime(), 90) <= 0 then
        athlete:castSkill(DesperateFight)
        athlete:addBuff(self.buff, athlete)
    end
end

return DesperateFight

local Skill = import("../Skill")

local DefenseCommandor = class(Skill, "DefenseCommandor")
DefenseCommandor.id = "E04"
DefenseCommandor.alias = "防线统领"

local minProbability = 1
local maxProbability = 1
DefenseCommandor.minAddConfig = 0.11
DefenseCommandor.maxAddConfig = 1.1
DefenseCommandor.minAddCommandingMultiply = 0.55
DefenseCommandor.maxAddCommandingMultiply = 5.5

function DefenseCommandor:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.remainingCooldown = 0
    self.probability = Skill.lerpLevel(minProbability, maxProbability, level)
    self.addCommandingMultiply = Skill.lerpLevel(self.minAddCommandingMultiply, self.maxAddCommandingMultiply, level)
    self.addRatio = Skill.lerpLevel(self.minAddConfig, self.maxAddConfig, level)

    self.buff = {
        skill = self,
        remark = "ignoreCannotAddBuffDebuff",
        removalCondition = function(remainingTime, caster, receiver)
            return caster.onfieldId == nil
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio
        end,
        persistent = true
    }
end

function DefenseCommandor:enterField(athlete)
    athlete:addBuff(self.buff, athlete)
end

return DefenseCommandor

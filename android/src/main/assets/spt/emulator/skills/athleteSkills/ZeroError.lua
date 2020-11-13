local Skill = import("../Skill")

local ZeroError = class(Skill, "ZeroError")
ZeroError.id = "E01"
ZeroError.alias = "零失误"

local minProbabilityConfig = 1
local maxProbabilityConfig = 1
local minAddConfig = 0.11
local maxAddConfig = 1.1
local minAddSaveMultiply = 0.88
local maxAddSaveMultiply = 8.8

function ZeroError:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.remainingCooldown = 0
    self.probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
    self.addSaveMultiply = Skill.lerpLevel(minAddSaveMultiply, maxAddSaveMultiply, level)
    self.addRatio = Skill.lerpLevel(minAddConfig, maxAddConfig, level)

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

function ZeroError:enterField(athlete)
    athlete:addBuff(self.buff, athlete)
end

return ZeroError
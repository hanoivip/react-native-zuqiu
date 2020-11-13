local Skill = import("../Skill")

local GodReaction = class(Skill, "GodReaction")
GodReaction.id = "E02"
GodReaction.alias = "神级反应"

local minProbabilityConfig = 1
local maxProbabilityConfig = 1
local minAddConfig = 0.11
local maxAddConfig = 1.1
local minAddAnticipationMultiply = 0.88
local maxAddAnticipationMultiply = 8.8

function GodReaction:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.remainingCooldown = 0
    self.probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
    self.addAnticipationMultiply = Skill.lerpLevel(minAddAnticipationMultiply, maxAddAnticipationMultiply, level)
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

function GodReaction:enterField(athlete)
    athlete:addBuff(self.buff, athlete)
end

return GodReaction

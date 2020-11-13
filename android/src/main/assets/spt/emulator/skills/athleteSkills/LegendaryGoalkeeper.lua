local Skill = import("../Skill")

local LegendaryGoalkeeper = class(Skill, "LegendaryGoalkeeper")
LegendaryGoalkeeper.id = "E03"
LegendaryGoalkeeper.alias = "门神下凡"

local minProbabilityConfig = 1
local maxProbabilityConfig = 1
local minAddConfig = 0.11
local maxAddConfig = 1.1
local minAddComposureMultiply = 0.88
local maxAddComposureMultiply = 8.8

function LegendaryGoalkeeper:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.remainingCooldown = 0
    self.probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
    self.addComposureMultiply = Skill.lerpLevel(minAddComposureMultiply, maxAddComposureMultiply, level)
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

function LegendaryGoalkeeper:enterField(athlete)
    athlete:addBuff(self.buff, athlete)
end

return LegendaryGoalkeeper
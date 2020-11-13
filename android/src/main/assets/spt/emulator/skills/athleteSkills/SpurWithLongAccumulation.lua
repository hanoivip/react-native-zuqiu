local Skill = import("../Skill")

local SpurWithLongAccumulation = class(Skill, "SpurWithLongAccumulation")
SpurWithLongAccumulation.id = "M13"
SpurWithLongAccumulation.alias = "厚积薄发"

local cooldownConfig = 0
local minInitAddConfig = 0.05
local maxInitAddConfig = 5
local minAddConfig = 0.1
local maxAddConfig = 10
local minSubConfig = 0.15
local maxSubConfig = 15

function SpurWithLongAccumulation:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.remainingCooldown = 0
    self.initRatio = Skill.lerpLevel(minInitAddConfig, maxInitAddConfig, level)
    self.addRatio = Skill.lerpLevel(minAddConfig, maxAddConfig, level)
    self.subRatio = -Skill.lerpLevel(minSubConfig, maxSubConfig, level)

    self.initBuff = {
        skill = self,
        remark = "ignoreCannotAddBuffDebuff",
        removalCondition = function(remainingTime, caster, receiver)
            return false
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.initRatio
        end,
        persistent = true
    }
    self.buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return false
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio
        end,
        persistent = true
    }
    self.debuff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return false
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.subRatio
        end,
        persistent = true        
    }
end

function SpurWithLongAccumulation:enterField(athlete)
    athlete:castSkill(SpurWithLongAccumulation)
    athlete:addBuff(self.initBuff, athlete)
    if athlete.match.hasFirstGoal then
        if athlete.team.isFirstGoalTeam then
            athlete:addBuff(self.buff, athlete)
        else
            athlete:addBuff(self.debuff, athlete)
        end
    end
end


return SpurWithLongAccumulation
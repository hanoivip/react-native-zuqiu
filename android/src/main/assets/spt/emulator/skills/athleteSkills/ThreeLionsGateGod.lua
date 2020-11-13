local Skill = import("../Skill")

local ThreeLionsGateGod = class(Skill, "ThreeLionsGateGod")
ThreeLionsGateGod.id = "LR_DSEAMAN2"
ThreeLionsGateGod.alias = "三狮门神"

local minProbabilityConfig = 0.25
local maxProbabilityConfig = 0.25
local minAddRatio = 0.5
local maxAddRatio = 0.5
local minAddRatio1 = 0.06
local maxAddRatio1 = 0.06

function ThreeLionsGateGod:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.remainingCooldown = 0
    self.probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
    self.addRatio = Skill.lerpLevel(minAddRatio, maxAddRatio, level)
    self.addRatio1 = Skill.lerpLevel(minAddRatio1, maxAddRatio1, level)

    self.buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.team:isAttackRole()
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio
        end
    }

    self.buffSign = {
        skill = self,
        remark = "buffSign",
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.team:isAttackRole()
        end,
        persistent = true
    }

    self.selfBuff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return false
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio1
        end,
        persistent = true
    }
end

return ThreeLionsGateGod

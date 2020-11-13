local Skill = import("../Skill")

local RomanWarSpirit = class(Skill, "RomanWarSpirit")
RomanWarSpirit.id = "LR_DDEROSSI2"
RomanWarSpirit.alias = "罗马战魂"

-- 加全属性概率
local minBuffProbabilityConfig = 0.15
local maxBuffProbabilityConfig = 0.15
-- 清空debuff概率
local minBuff1ProbabilityConfig = 0.2
local maxBuff1ProbabilityConfig = 0.2
local minAddRatio = 0.5
local maxAddRatio = 0.5

function RomanWarSpirit:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.remainingCooldown = 0
    -- 加全属性概率
    self.probability = Skill.lerpLevel(minBuffProbabilityConfig, maxBuffProbabilityConfig, level)
    -- 清空debuff概率
    self.probability1 = Skill.lerpLevel(minBuff1ProbabilityConfig, maxBuff1ProbabilityConfig, level)
    self.addRatio = Skill.lerpLevel(minAddRatio, maxAddRatio, level)

    self.buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.team:isAttackRole()
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio
        end,
        persistent = true
    }
end

return RomanWarSpirit

local Skill = import("../Skill")
local PenaltyKickKiller = import("./PenaltyKickKiller")

local PenaltyKickKillerEx1 = class(PenaltyKickKiller, "PenaltyKickKillerEx1")
PenaltyKickKillerEx1.id = "E07_1"
PenaltyKickKillerEx1.alias = "点球杀手"

-- 自身全属性增强配置
local minAddAbilityConfig = 0.11
local maxAddAbilityConfig = 1.1
-- 敌方心灰意冷全属性下降配置
local minSubAbilityConfig = 0.75
local maxSubAbilityConfig = 0.75
-- 心灰意冷概率配置
local minDebuffProbabilityConfig = 1
local maxDebuffProbabilityConfig = 1
-- 心灰意冷持续时间
local debuffDuration = 35

function PenaltyKickKillerEx1:ctor(level)
    PenaltyKickKiller.ctor(self, level)

    self.addRatio = Skill.lerpLevel(minAddAbilityConfig, maxAddAbilityConfig, level)
    self.subRatio = -Skill.lerpLevel(minSubAbilityConfig, maxSubAbilityConfig, level)
    self.ex1DebuffProbability = Skill.lerpLevel(minDebuffProbabilityConfig, maxDebuffProbabilityConfig, level)
    self.targetEnemy = nil
    self.ex1Debuff = {
        skill = self,
        duration = debuffDuration,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.onfieldId == nil or math.cmpf(remainingTime, 0) <= 0 
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.subRatio
        end,
    }

    self.ex1MarkedDebuff = {
        skill = self,
        remark = "mark",
        duration = debuffDuration,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.onfieldId == nil or math.cmpf(remainingTime, 0) <= 0 
        end,
        abilitiesAddRatio = function(caster, receiver)
            return 0
        end,
    }

    self.ex1BuffSign = {
        skill = self,
        remark = "buffSign",
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.onfieldId == nil or receiver.team:isAttackRole() or receiver.match.ball.lastTouchAthlete ~= nil and receiver.match.ball.lastTouchAthlete == receiver
        end,
    }
    self.ex1Buff = {
        skill = self,
        remark = "ignoreCannotAddBuffDebuff",
        removalCondition = function(remainingTime, caster, receiver)
            return false
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio
        end,
        persistent = true
    }
end

function PenaltyKickKillerEx1:enterField(athlete)
    athlete:addBuff(self.ex1Buff, athlete)
end

return PenaltyKickKillerEx1
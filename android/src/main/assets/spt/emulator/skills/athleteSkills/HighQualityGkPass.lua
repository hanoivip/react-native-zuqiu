local Skill = import("../Skill")

local HighQualityGkPass = class(Skill, "HighQualityGkPass")
HighQualityGkPass.id = "E10"
HighQualityGkPass.alias = "高质量出球"

local cooldownConfig = 0
local minProbabilityConfig = 1
local maxProbabilityConfig = 1
local minSelfAddConfig = 0.11
local maxSelfAddConfig = 1.1
local minPassTargetAddConfig = 0.66
local maxPassTargetAddConfig = 6.6

function HighQualityGkPass:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.cooldown = cooldownConfig
    self.remainingCooldown = 0
    self.probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
    self.selfAddRatio = Skill.lerpLevel(minSelfAddConfig, maxSelfAddConfig, level)

    self.selfBuff = {
        skill = self,
        remark = "ignoreCannotAddBuffDebuff",
        removalCondition = function(remainingTime, caster, receiver)
            return caster.onfieldId == nil
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.selfAddRatio
        end,
        persistent = true
    }

    self.passTargetBuff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.onfieldId == nil
        end,
        abilitiesAddRatio = function(caster, receiver)
            local addedValue = caster.initAbilities.launching * Skill.lerpLevel(minPassTargetAddConfig, maxPassTargetAddConfig, level)
            return addedValue / receiver.initAbilitiesSum
        end,
        persistent = true
    }
end

function HighQualityGkPass:enterField(athlete)
    athlete:addBuff(self.selfBuff, athlete)
end

return HighQualityGkPass

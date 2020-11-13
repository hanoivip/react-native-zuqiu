local Skill = import("../Skill")
local PenaltyBoxSignalFireTurret = import("./PenaltyBoxSignalFireTurret")

local PenaltyBoxSignalFireTurretEx1 = class(PenaltyBoxSignalFireTurret, "PenaltyBoxSignalFireTurretEx1")
PenaltyBoxSignalFireTurretEx1.id = "E11_1"
PenaltyBoxSignalFireTurretEx1.alias = "禁区烽火台"

local minProbabilityConfig = 0.8
local maxProbabilityConfig = 0.8
local minAddConfig = 0.108
local maxAddConfig = 0.18
local minBaseAddConfig = 0.22
local maxBaseAddConfig = 2.2

function PenaltyBoxSignalFireTurretEx1:ctor(level)
    PenaltyBoxSignalFireTurret.ctor(self, level)

    self.ex1Probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
    self.ex1AddRatio = Skill.lerpLevel(minAddConfig, maxAddConfig, level)
    self.ex1BaseAddRatio = Skill.lerpLevel(minBaseAddConfig, maxBaseAddConfig, level)

    self.ex1Buff = {
        skill = self,
        remark = "ignoreCannotAddBuffDebuff",
        removalCondition = function(remainingTime, caster, receiver)
            return false
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.ex1AddRatio
        end,
        persistent = true
    }

    self.ex1BaseBuff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return false
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.ex1BaseAddRatio
        end,
        persistent = true
    }
end

function PenaltyBoxSignalFireTurretEx1:enterField(athlete)
    athlete:addBuff(self.ex1BaseBuff, athlete)
end

return PenaltyBoxSignalFireTurretEx1
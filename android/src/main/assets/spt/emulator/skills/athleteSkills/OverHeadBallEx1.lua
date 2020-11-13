local Skill = import("../Skill")
local OverHeadBall = import("./OverHeadBall")

local OverHeadBallEx1 = class(OverHeadBall, "OverHeadBallEx1")
OverHeadBallEx1.id = "C02_1"
OverHeadBallEx1.alias = "过顶球"

local minBasePassConfig = 0.05
local maxBasePassConfig = 0.05
local minSubConfig = 0.7
local maxSubConfig = 0.7

function OverHeadBallEx1:ctor(level)
    OverHeadBall.ctor(self, level)

    self.subRatio = -Skill.lerpLevel(minSubConfig, maxSubConfig, level)

    self.ex1Buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return false
        end,
        abilitiesModifier = function(abilities, caster, receiver)
            abilities.pass = abilities.pass + receiver.initAbilities.pass * Skill.lerpLevel(minBasePassConfig, maxBasePassConfig, level)
        end,
        persistent = true
    }

    self.ex1Debuff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return caster.match.ball.nextTask and caster.match.ball.nextTask.isGoal and caster.match.ball.nextTask.shooter.team == caster.team
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.subRatio
        end,
        persistent = true
    }
end

function OverHeadBallEx1:enterField(athlete)
    OverHeadBall.enterField(self, athlete)
    athlete:addBuff(self.ex1Buff, athlete)
end

return OverHeadBallEx1

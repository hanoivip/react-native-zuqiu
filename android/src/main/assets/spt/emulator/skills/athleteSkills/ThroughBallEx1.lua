local Skill = import("../Skill")
local ThroughBall = import("./ThroughBall")

local ThroughBallEx1 = class(ThroughBall, "ThroughBallEx1")
ThroughBallEx1.id = "C01_1"
ThroughBallEx1.alias = "手术刀直塞"

local minBasePassConfig = 0.1
local maxBasePassConfig = 0.1
local minSubConfig = 0.5
local maxSubConfig = 0.5

function ThroughBallEx1:ctor(level)
    ThroughBall.ctor(self, level)

    self.subRatio = -Skill.lerpLevel(minSubConfig, maxSubConfig, level)

    self.ex1Buff = {
        skill = self,
        remark = "ignoreCannotAddBuffDebuff",
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

function ThroughBallEx1:enterField(athlete)
    athlete:addBuff(self.ex1Buff, athlete)
end

return ThroughBallEx1

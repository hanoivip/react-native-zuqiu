local Skill = import("../Skill")
local Ball = import("../../Ball")
local GoldenWolfDirect = import("./GoldenWolfDirect")
local ThroughBallEx1 = import("./ThroughBallEx1")

local GoldenWolfDirectEx1 = class(ThroughBallEx1, "GoldenWolfDirectEx1")
GoldenWolfDirectEx1.id = "C01_A_1"
GoldenWolfDirectEx1.alias = "金狼直传"

local minProbabilityConfig = 1
local maxProbabilityConfig = 1

function GoldenWolfDirectEx1:ctor(level)
    if GoldenWolfDirect.initConfig then
        GoldenWolfDirect:initConfig(self)
    end
    ThroughBallEx1.ctor(self, level)
    self.exa1Probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)

    self.exa1Debuff = {
        skill = self,
        remark = "mark",
        removalCondition = function(remainingTime, caster, receiver)
            return caster.match.ball.nextTask and caster.match.ball.nextTask.isGoal and caster.match.ball.nextTask.shooter.team == caster.team
        end,
        abilitiesAddRatio = function(caster, receiver)
            return 0
        end,
        persistent = true
    }
end

function GoldenWolfDirectEx1:enterField(athlete)
    ThroughBallEx1.enterField(self, athlete)
end

return GoldenWolfDirectEx1

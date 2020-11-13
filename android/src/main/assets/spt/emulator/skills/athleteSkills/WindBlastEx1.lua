local Skill = import("../Skill")
local WindBlast = import("./WindBlast")
local ImpactWaveEx1 = import("./ImpactWaveEx1")

local WindBlastEx1 = class(ImpactWaveEx1, "WindBlastEx1")
WindBlastEx1.id = "D05_A_1"
WindBlastEx1.alias = "旋风冲击"

local minProbabilityConfig = 0.3
local maxProbabilityConfig = 0.3

function WindBlastEx1:ctor(level)
    if WindBlast.initConfig then
        WindBlast:initConfig(self)
    end
    ImpactWaveEx1.ctor(self, level)
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

return WindBlastEx1

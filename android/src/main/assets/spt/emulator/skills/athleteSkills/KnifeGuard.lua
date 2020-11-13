local Skill = import("../Skill")
local Ball = import("../../Ball")

local KnifeGuard = class(Skill, "KnifeGuard")
KnifeGuard.id = "F06"
KnifeGuard.alias = "带刀侍卫"

local minAbilitiesSumMultiply = 0.33
local maxAbilitiesSumMultiply = 3.3

function KnifeGuard:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.remainingCooldown = 0
    self.abilitiesSumMultiply = Skill.lerpLevel(minAbilitiesSumMultiply, maxAbilitiesSumMultiply, level)

    self.buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.match.ball.nextTask and receiver.match.ball.nextTask.class == Ball.ShootAndSave
        end,
    }
end

return KnifeGuard

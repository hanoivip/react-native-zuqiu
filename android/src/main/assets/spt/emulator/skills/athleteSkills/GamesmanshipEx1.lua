local Skill = import("../Skill")
local Gamesmanship = import("./Gamesmanship")

local GamesmanshipEx1 = class(Gamesmanship, "GamesmanshipEx1")
GamesmanshipEx1.id = "A02_1"
GamesmanshipEx1.alias = "小动作"

local minProbabilityConfig = 1
local maxProbabilityConfig = 1
-- 小动作射门结算时减少成功率
local minDecreaseConfig = 0.04
local maxDecreaseConfig = 0.04
-- debuff累计次数
local debuffCounterConfig = 3

function GamesmanshipEx1:ctor(level)
    Gamesmanship.ctor(self, level)
    self.debuffCount = debuffCounterConfig
    self.ex1Probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
    self.ex1GoalProbability = -Skill.lerpLevel(minDecreaseConfig, maxDecreaseConfig, level)

    self.ex1Debuff = {
        skill = self,
        remark = "mark",
        removalCondition = function(remainingTime, caster, receiver)
            return caster.team:isAttackRole()
        end,
        abilitiesAddRatio = function(caster, receiver)
            return 0
        end,
        persistent = true
    }
end

return GamesmanshipEx1
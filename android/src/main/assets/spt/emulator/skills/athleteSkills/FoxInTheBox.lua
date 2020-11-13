local Skill = import("../Skill")
local Ball = import("../../Ball")
local ThroughBall = import("./ThroughBall")

local FoxInTheBox = class(Skill, "FoxInTheBox")
FoxInTheBox.id = "D02"
FoxInTheBox.alias = "禁区之狐"

local cooldownConfig = 0
local minProbabilityConfig = 1
local maxProbabilityConfig = 1
local minAddShootMultiply = 0.55
local maxAddShootMultiply = 5.5

function FoxInTheBox:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.cooldown = cooldownConfig
    self.remainingCooldown = 0
    self.probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
    self.addShootMultiply = Skill.lerpLevel(minAddShootMultiply, maxAddShootMultiply, level)

    self.buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return (receiver.match.ball.nextTask and receiver.match.ball.nextTask.class == Ball.ShootAndSave)
                or receiver.team:isDefendRole()
        end,
        abilitiesModifier = function(abilities, caster, receiver)
            if AIUtils.isSkillIdCorrespondSkill(receiver.match.ball.nextTask.skillId, ThroughBall) then
                abilities.isBlockedDisabled = true
            end
        end
    }
end

return FoxInTheBox

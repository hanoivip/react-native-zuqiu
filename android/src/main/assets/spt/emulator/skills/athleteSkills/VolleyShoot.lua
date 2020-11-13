local Skill = import("../Skill")
local Ball = import("../../Ball")
local OverHeadBall = import("./OverHeadBall")
local PuntKick = import("./PuntKick")

local VolleyShoot = class(Skill, "VolleyShoot")
VolleyShoot.id = "D04"
VolleyShoot.alias = "凌空抽射"

local cooldownConfig = 0
local minProbabilityConfig = 1
local maxProbabilityConfig = 1
local minAddShootMultiply = 0.55
local maxAddShootMultiply = 5.5

function VolleyShoot:ctor(level)
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
            local nextTask = receiver.match.ball.nextTask
            if AIUtils.isSkillIdCorrespondSkill(nextTask.skillId, OverHeadBall) or AIUtils.isSkillIdCorrespondSkill(nextTask.skillId, PuntKick) then
                abilities.isBlockedDisabled = true
            end
        end
    }
end

return VolleyShoot

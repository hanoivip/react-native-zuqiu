local Skill = import("../Skill")

local OverHeadBall = class(Skill, "OverHeadBall")
OverHeadBall.id = "C02"
OverHeadBall.alias = "过顶球"

local cooldownConfig = 18
local minProbabilityConfig = 0.45
local maxProbabilityConfig = 0.45
local minSideProbabilityConfig = 0.2
local maxSideProbabilityConfig = 0.2
local minPassConfig = 0.55
local maxPassConfig = 5.5

local limitRoles = {
    16,
    20,
    21,
    25,
}

function OverHeadBall:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.cooldown = cooldownConfig
    self.remainingCooldown = 0
    self.probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)

    self.buff = {
        skill = self,
        remark = "base",
        removalCondition = function(remainingTime, caster, receiver)
            return not receiver:hasBall()
        end,
        abilitiesModifier = function(abilities, caster, receiver)
             abilities.pass = abilities.pass + receiver.initAbilities.pass * Skill.lerpLevel(minPassConfig, maxPassConfig, level)
        end
    }
end

function OverHeadBall:enterField(athlete)
    for i, role in ipairs(limitRoles) do
        if athlete.role == role then
            self.probability = Skill.lerpLevel(minSideProbabilityConfig, maxSideProbabilityConfig, self.level)
            athlete:checkAdeptRoleState()
            return
        end
    end
    athlete:checkAdeptRoleState()
end

return OverHeadBall

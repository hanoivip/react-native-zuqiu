local Skill = import("../Skill")

local Metronome = class(Skill, "Metronome")
Metronome.id = "B03"
Metronome.alias = "节拍器"

local cooldownConfig = 0
local minProbabilityConfig = 1
local maxProbabilityConfig = 1
Metronome.minAddConfig = 0.22
Metronome.maxAddConfig = 2.2

function Metronome:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.cooldown = cooldownConfig
    self.remainingCooldown = 0
    self.probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
    self.addRatio = Skill.lerpLevel(self.minAddConfig, self.maxAddConfig, level)
    self.hasLaunched = false

    self.buff = {
        skill = self,
        remark = "base",
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.team:isDefendRole()
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio
        end,
    }

    self.teamLeaderAddRatio = 0
    
    self.teamLeaderBuff = {
        skill = self,
        remark = "base",
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.team:isDefendRole()
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.teamLeaderAddRatio
        end,
    }
end

return Metronome
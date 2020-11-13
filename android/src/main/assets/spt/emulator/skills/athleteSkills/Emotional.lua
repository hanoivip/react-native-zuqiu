local Skill = import("../Skill")
local ChargeTrumpet = import("./ChargeTrumpet")
local Metronome = import("./Metronome")
local FightTogether = import("./FightTogether")

local Emotional = class(Skill, "Emotional")
Emotional.id = "M14"
Emotional.alias = "情绪化"

local cooldownConfig = 0
local minAddConfig = 0.2
local maxAddConfig = 20

function Emotional:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.remainingCooldown = 0
    self.initRatio = Skill.lerpLevel(minAddConfig, maxAddConfig, level)
    self.addRatio = Skill.lerpLevel(minAddConfig, maxAddConfig, level)

    self.chargeTrumpetBuff = {
        skill = self,
        originalSkillClass = ChargeTrumpet,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.team:isDefendRole()
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio
        end,
    }

    self.metronomeBuff = {
        skill = self,
        originalSkillClass = Metronome,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.team:isDefendRole()
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio
        end,
    }

    self.fightTogetherBuff = {
        skill = self,
        originalSkillClass = FightTogether,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.team:isAttackRole()
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio
        end,
    }
end

return Emotional
local Skill = import("../Skill")

local NouCampElves = class(Skill, "NouCampElves")
NouCampElves.id = "LR_LMESSI2"
NouCampElves.alias = "诺坎普精灵"

NouCampElves.minAddAbilityConfig = 0.4
NouCampElves.maxAddAbilityConfig = 0.4

function NouCampElves:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.remainingCooldown = 0
    self.addRatio = Skill.lerpLevel(self.minAddAbilityConfig, self.maxAddAbilityConfig, level)

    self.buff = {
        skill = self,
        remark = "ignoreCannotAddBuffDebuff",
        removalCondition = function(remainingTime, caster, receiver)
            return false
        end,
        abilitiesModifier = function(abilities, caster, receiver)
            abilities.dribble = abilities.dribble + receiver.initAbilities.dribble * self.addRatio
        end,
        persistent = true
    }
end

function NouCampElves:enterField(athlete)
    athlete:castSkill(self)
    athlete:addBuff(self.buff, athlete)
end

return NouCampElves

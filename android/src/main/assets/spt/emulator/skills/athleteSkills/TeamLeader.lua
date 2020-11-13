local Skill = import("../Skill")

local TeamLeader = class(Skill, "TeamLeader")
TeamLeader.id = "F01"
TeamLeader.alias = "团队领袖"

local minAddConfig = 0.055
local maxAddConfig = 0.55

function TeamLeader:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.cooldown = 0
    self.remainingCooldown = 0
    self.addRatio = Skill.lerpLevel(minAddConfig, maxAddConfig, level)

    self.buff = {
        skill = self,
        remark = "ignoreCannotAddBuffDebuff",
        removalCondition = function(remainingTime, caster, receiver)
            return caster.onfieldId == nil or caster ~= caster.team.captainPlayer
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio
        end,
        persistent = true
    }
end

function TeamLeader:enterField(athlete)
    if athlete.team.captain == athlete.role then
        for i, a in ipairs(athlete.team.athletes) do
            a:addBuff(self.buff, athlete)
        end

        athlete.captainEnterFieldTime = athlete.match.currentTime
    end
end

return TeamLeader

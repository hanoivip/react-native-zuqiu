local Skill = import("../Skill")

local OrganizeWall = class(Skill, "OrganizeWall")
OrganizeWall.id = "E08"
OrganizeWall.alias = "指挥人墙"

local minAddCommandingConfig = 0.66
local maxAddCommandingConfig = 6.6

function OrganizeWall:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.remainingCooldown = 0
    self.addCommandingConfig = Skill.lerpLevel(minAddCommandingConfig, maxAddCommandingConfig, level)

    self.buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.match.ball.owner == nil
        end,
    }
end

return OrganizeWall
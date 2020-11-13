local CoachSkill = import("./CoachSkill")

local KillTalent = class(CoachSkill, "KillTalent")
KillTalent.id = 314
KillTalent.alias = "绝杀天赋"

local attackConfig = 2.0
local timeConfig = 75

function KillTalent:ctor()
    CoachSkill.ctor(self)
    self.triggered = nil

    self.buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.onfieldId == nil or
                receiver.match.PENALTY_SHOOTOUT_STAGE <= receiver.match.stage
        end,
        abilitiesModifier = function(abilities)
            abilities.dribble = abilities.dribble * attackConfig
            abilities.pass = abilities.pass * attackConfig
            abilities.shoot = abilities.shoot * attackConfig
        end,
        persistent = true
    }
end

function KillTalent:execute(team)
    if self.triggered or
        self.scoreStatus ~= self.DRAW or
        math.cmpf(team.match:getDisplayTime(), timeConfig) < 0 or
        team.match.PENALTY_SHOOTOUT_STAGE <= team.match.stage then
        return
    end
    for _, athlete in ipairs(team.athletes) do
        athlete:addBuff(self.buff, team)
    end
    team:castCoachSkill(self.id)
    self.triggered = true
end

function KillTalent:update(team)
    if math.cmpf(team.match:getDisplayTime(), timeConfig) ~= 0 then
        return
    end
    self:execute(team)
end

function KillTalent:onBecomingDraw(team)
    self:execute(team)
end

return KillTalent 
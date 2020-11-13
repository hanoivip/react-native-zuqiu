local CoachSkill = import("./CoachSkill")

local DrawTalent = class(CoachSkill, "DrawTalent")
DrawTalent.id = 414
DrawTalent.alias = "平局大师天赋"

local laggardConfig = 1.6
local leaderConfig = 0.5

function DrawTalent:ctor()
    CoachSkill.ctor(self)
    self.config = 1.0

    self.buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.onfieldId == nil or 
                self.scoreStatus == self.DRAW or
                receiver.match.PENALTY_SHOOTOUT_STAGE <= receiver.match.stage
        end,
        abilitiesModifier = function(abilities)
            abilities.dribble = abilities.dribble * self.config
            abilities.pass = abilities.pass * self.config
            abilities.shoot = abilities.shoot * self.config
        end,
        persistent = true
    }
end

function DrawTalent:execute(team)
    for _, athlete in ipairs(team.athletes) do
        athlete:addBuff(self.buff, team)
    end
    team:castCoachSkill(self.id)
end

function DrawTalent:onBecomingLeader(team)
    self.config = leaderConfig
    self:execute(team)
end

function DrawTalent:onBecomingLaggard(team)
    self.config = laggardConfig
    self:execute(team)
end

return DrawTalent 

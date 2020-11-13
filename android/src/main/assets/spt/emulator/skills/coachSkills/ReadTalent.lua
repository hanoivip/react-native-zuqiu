local CoachSkill = import("./CoachSkill")

local ReadTalent = class(CoachSkill, "ReadTalent")
ReadTalent.id = 814
ReadTalent.alias = "比赛阅读天赋"

local attributeConfig = 0.05
local intervalConfig = 30

function ReadTalent:ctor()
    CoachSkill.ctor(self)
    self.skillStartTime = -1
    self.count = 0

    self.buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.onfieldId == nil or 
                receiver.match.PENALTY_SHOOTOUT_STAGE <= receiver.match.stage
        end,
        abilitiesModifier = function(abilities)
            local ratio = attributeConfig * self.count + 1
            abilities.dribble = abilities.dribble * ratio
            abilities.pass = abilities.pass * ratio
            abilities.shoot = abilities.shoot * ratio
            abilities.steal = abilities.steal * ratio
            abilities.intercept = abilities.intercept * ratio
            abilities.goalkeeping = abilities.goalkeeping * ratio
        end,
        persistent = true
    }
end

function ReadTalent:enterStage(team)
    if team.match.stage ~= team.match.FIRST_HALF_STAGE then
        return
    end
    self.skillStartTime = team.match.currentTime
    for _, athlete in ipairs(team.athletes) do
        athlete:addBuff(self.buff, team)
    end
    team:castCoachSkill(self.id)
end

function ReadTalent:update(team)
    local newCount = 0
    if 0 < math.cmpf(self.skillStartTime, -1) then
        newCount = (team.match.currentTime - self.skillStartTime) / intervalConfig
    end
    newCount = math.floor(newCount + math.eps)
    if newCount ~= self.count then
        for _, athlete in ipairs(team.athletes) do
            athlete:setCachedAbilitiesDirty()
        end
        self.count = newCount
    end
end

return ReadTalent
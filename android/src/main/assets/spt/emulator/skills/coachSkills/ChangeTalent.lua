local CoachSkill = import("./CoachSkill")

local ChangeTalent = class(CoachSkill, "ChangeTalent")
ChangeTalent.id = 914
ChangeTalent.alias = "应变天赋"

local attributeConfig = 0.05

function ChangeTalent:ctor()
    CoachSkill.ctor(self)
    self.score = 0

    self.buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.onfieldId == nil or 
                receiver.match.PENALTY_SHOOTOUT_STAGE <= receiver.match.stage
        end,
        abilitiesModifier = function(abilities)
            local ratio = attributeConfig * self.score + 1
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

function ChangeTalent:enterStage(team)
    if team.match.stage ~= team.match.FIRST_HALF_STAGE then
        return
    end
    for _, athlete in ipairs(team.athletes) do
        athlete:addBuff(self.buff, team)
    end
end

function ChangeTalent:onGoal(team)
    self.score = team.score + team.enemyTeam.score
    for _, athlete in ipairs(team.athletes) do
        athlete:setCachedAbilitiesDirty()
    end
    team:castCoachSkill(self.id)
end

return ChangeTalent
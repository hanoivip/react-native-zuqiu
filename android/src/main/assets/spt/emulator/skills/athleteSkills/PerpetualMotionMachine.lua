local Skill = import("../Skill")

local PerpetualMotionMachine = class(Skill, "PerpetualMotionMachine")
PerpetualMotionMachine.id = "G01"
PerpetualMotionMachine.alias = "永动机"

local intervalConfig = 20
PerpetualMotionMachine.minAddConfig = 0.033
PerpetualMotionMachine.maxAddConfig = 0.33

function PerpetualMotionMachine:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.remainingCooldown = 0
    self.level = level
    self.skillStartTime = -1
    self.count = 0
    self.interval = intervalConfig
    self.addRatio = Skill.lerpLevel(self.minAddConfig, self.maxAddConfig, level)
    
    self.buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.onfieldId == nil
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio
        end,
        persistent = true
    }

    self.teamLeaderAddRatio = 0
    
    self.teamLeaderBuff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return caster.onfieldId == nil or receiver.onfieldId == nil
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.teamLeaderAddRatio
        end,
    }
end

function PerpetualMotionMachine:enterField(athlete)
    self.skillStartTime = athlete.match.currentTime
end

function PerpetualMotionMachine:update(athlete)
    if athlete.onfieldId == nil then
        return false
    end
    local newCount = 0
    if math.cmpf(self.skillStartTime, -1) > 0 then
        newCount = (athlete.match.currentTime - self.skillStartTime) / intervalConfig
    end
    newCount = math.floor(newCount + math.eps)
    if newCount ~= self.count then
        athlete:setCachedAbilitiesDirty()
        self.count = newCount
        local skill = athlete:getSkill(PerpetualMotionMachine)
        athlete:castSkill(skill.class, self.addRatio)
        athlete:addBuff(self.buff, athlete)
        athlete:judgeTeamLeaderEx1(self)
        return true
    end
    return false
end

return PerpetualMotionMachine

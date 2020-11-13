local Skill = import("../Skill")

local GlobalCommand = class(Skill, "GlobalCommand")
GlobalCommand.id = "F08"
GlobalCommand.alias = "统领指挥"

local minAddConfig = 0.0605
local maxAddConfig = 0.605

function GlobalCommand:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.remainingCooldown = 0
    self.level = level
    self.addRatio = Skill.lerpLevel(minAddConfig, maxAddConfig, level)
    -- 如果有多个球员有该技能，标识当前技能在这一组技能中的发动顺序
    self.launchIndex = nil

    self.buff = {
        skill = self,
        remark = "ignoreCannotAddBuffDebuff",
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.onfieldId == nil
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio
        end,
        persistent = true
    }
end

function GlobalCommand:enterField(athlete)
    local team = athlete.team

    if self.launchIndex == nil then
        Skill.calcLaunchIndex(team, GlobalCommand)
    end

    self.addRatio = self.addRatio / math.pow(2, (self.launchIndex - 1))

    if math.cmpf(self.addRatio, 0.01) < 0 then
        self.addRatio = 0.01
    end
    
    for _, itemAthlete in ipairs(team.athletes) do
        if itemAthlete.role >= 16 and itemAthlete.role <= 26 then
            itemAthlete:addBuff(self.buff, itemAthlete)
        end
    end

    athlete:castSkill(GlobalCommand, self.addRatio)
end

return GlobalCommand

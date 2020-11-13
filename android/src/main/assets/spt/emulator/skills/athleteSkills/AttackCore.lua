local Skill = import("../Skill")

local AttackCore = class(Skill, "AttackCore")
AttackCore.id = "F07"
AttackCore.alias = "进攻核心"

local minAddConfig = 0.0605
local maxAddConfig = 0.605

function AttackCore:ctor(level)
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

function AttackCore:enterField(athlete)
    local team = athlete.team

    if self.launchIndex == nil then
        Skill.calcLaunchIndex(team, AttackCore)
    end

    self.addRatio = self.addRatio / math.pow(2, (self.launchIndex - 1))

    if math.cmpf(self.addRatio, 0.01) < 0 then
        self.addRatio = 0.01
    end

    for _, itemAthlete in ipairs(team.athletes) do
        if itemAthlete.role >= 1 and itemAthlete.role <= 15 then
            itemAthlete:addBuff(self.buff, itemAthlete)
        end
    end

    athlete:castSkill(AttackCore, self.addRatio)
end

return AttackCore

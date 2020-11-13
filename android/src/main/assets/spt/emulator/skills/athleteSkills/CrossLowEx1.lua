local Skill = import("../Skill")
local Field = import("../../Field")
local CrossLow = import("./CrossLow")

local CrossLowEx1 = class(CrossLow, "CrossLowEx1")
CrossLowEx1.id = "C03_1"
CrossLowEx1.alias = "下底传中"

-- 边路带球属性增加配置(增加带球属性曲线救国)
local minDribbleAddConfig = 0.15
local maxDribbleAddConfig = 0.15
-- 技能传球属性增加配置(增加传球属性曲线救国)
local minPassAddConfig = 0.15
local maxPassAddConfig = 3.12

function CrossLowEx1:ctor(level)
    CrossLow.ctor(self, level)
    
    self.ex1PassAddConfig = Skill.lerpLevel(minPassAddConfig, maxDribbleAddConfig, level)
    self.dribbleAddConfig = Skill.lerpLevel(minDribbleAddConfig, minDribbleAddConfig, level)

    self.buff = {
        skill = self,
        remark = "base",
        removalCondition = function(remainingTime, caster, receiver)
            return not receiver:hasBall()
        end,
        abilitiesModifier = function(abilities, caster, receiver)
            local exPassAddAbility = 0
            exPassAddAbility = math.max(abilities.dribble, abilities.pass)
            exPassAddAbility = math.max(exPassAddAbility, abilities.shoot)
            exPassAddAbility = math.max(exPassAddAbility, abilities.intercept)
            exPassAddAbility = math.max(exPassAddAbility, abilities.steal)
            abilities.pass = abilities.pass + receiver.initAbilities.pass * self.passAddConfig + exPassAddAbility * self.ex1PassAddConfig
        end
    }

    self.ex1DribbleBuff = {
        skill = self,
        remark = "ignoreCannotAddBuffDebuff",
        removalCondition = function(remainingTime, caster, receiver)
            return caster.onfieldId == nil
        end,
        abilitiesModifier = function(abilities, caster, receiver)
             abilities.dribble = (Field.isInLeftCourtArea(receiver.position, receiver.team:getSign()) or Field.isInLeftCourtArea(receiver.position, receiver.team:getSign()))
                                and abilities.dribble + receiver.initAbilities.dribble * self.dribbleAddConfig or abilities.dribble
        end,
        persistent = true
    }
end

function CrossLowEx1:enterField(athlete)
    athlete:castSkill(CrossLowEx1)
    athlete:addBuff(self.ex1DribbleBuff, athlete)
end

return CrossLowEx1

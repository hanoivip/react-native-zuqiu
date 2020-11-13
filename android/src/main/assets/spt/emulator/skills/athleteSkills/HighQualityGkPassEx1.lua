local Skill = import("../Skill")
local HighQualityGkPass = import("./HighQualityGkPass")

local HighQualityGkPassEx1 = class(HighQualityGkPass, "HighQualityGkPassEx1")
HighQualityGkPassEx1.id = "E10_1"
HighQualityGkPassEx1.alias = "高质量出球"

local targetCountConfig = 3

function HighQualityGkPassEx1:ctor(level)
    HighQualityGkPass.ctor(self, level)
    self.targetCount = targetCountConfig
    self.ex1BuffSign = {
        skill = self,
        remark = "buffSign",
        removalCondition = function(remainingTime, caster, receiver)
            if receiver:hasBall() then
                receiver:addBuff(self.ex1Buff, caster)
            end
            return receiver:hasBall() or not receiver.team:isAttackRole()
        end,
        abilitiesAddRatio = function(caster, receiver)
            return 0
        end,
        persistent = true
    }

    self.ex1Buff = {
        skill = self,
        remark = "passSuccess",
        removalCondition = function(remainingTime, caster, receiver)
            return not receiver:hasBall()
        end,
    }
end

function HighQualityGkPassEx1:enterField(athlete)
    HighQualityGkPass.enterField(self, athlete)
end

return HighQualityGkPassEx1

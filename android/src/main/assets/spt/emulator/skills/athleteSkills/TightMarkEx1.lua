local Skill = import("../Skill")
local TightMark = import("./TightMark")

local TightMarkEx1 = class(TightMark, "TightMarkEx1")
TightMarkEx1.id = "A08_1"
TightMarkEx1.alias = "盯人"

local minAddConfig = 0.65
local maxAddConfig = 0.65
local markRolesConfig = {
    1, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
}

function TightMarkEx1:ctor(level)
    TightMark.ctor(self, level)
    self.addConfigEx1 = Skill.lerpLevel(minAddConfig, maxAddConfig, level)
    self.markRoles = markRolesConfig
    self.ex1MarkedBuff = {
        skill = self,
        remark = "mark",
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.team:isDefendRole() or caster.onfieldId == nil
        end,
        abilitiesAddRatio = function(caster, receiver)
            return 0
        end,
    }
end

return TightMarkEx1

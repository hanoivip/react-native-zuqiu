local Skill = import("../Skill")
local CorePlayMaker = import("./CorePlayMaker")

local CorePlayMakerEx1 = class(CorePlayMaker, "CorePlayMakerEx1")
CorePlayMakerEx1.id = "C04_1"
CorePlayMakerEx1.alias = "组织核心"

local minFirstAddRatioConfig = 0.2
local maxFirstAddRatioConfig = 0.2
local minAddRatioConfig = 0.05
local maxAddRatioConfig = 0.05

function CorePlayMakerEx1:ctor(level)
    CorePlayMaker.ctor(self, level)

    self.ex1FirstAddRatio = Skill.lerpLevel(minFirstAddRatioConfig, maxFirstAddRatioConfig, level)
    self.ex1AddRatio = Skill.lerpLevel(minAddRatioConfig, maxAddRatioConfig, level)

    self.ex1Buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.team:isDefendRole()
        end, 
        abilitiesAddRatio = function(caster, receiver)
            return receiver:hasBuff(self, true) and self.ex1AddRatio or self.ex1FirstAddRatio
        end,
    }
end

return CorePlayMakerEx1

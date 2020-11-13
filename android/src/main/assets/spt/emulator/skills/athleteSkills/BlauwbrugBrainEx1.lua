local Skill = import("../Skill")
local CorePlayMakerEx1 = import("./CorePlayMakerEx1")
local BlauwbrugBrain = import("./BlauwbrugBrain")

local BlauwbrugBrainEx1 = class(CorePlayMakerEx1, "BlauwbrugBrainEx1")
BlauwbrugBrainEx1.id = "C04_A_1"
BlauwbrugBrainEx1.alias = "蓝桥大脑"

local minAddRatioConfig = 0.05
local maxAddRatioConfig = 0.05
local shortPassDistance = 20

function BlauwbrugBrainEx1:ctor(level)
    if BlauwbrugBrain.initConfig then
        BlauwbrugBrain:initConfig(self)
    end
    CorePlayMakerEx1.ctor(self, level)

    self.exa1Buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return true
        end,
        abilitiesModifier = function(abilities, caster, receiver)
            abilities.pass = abilities.pass + caster.initAbilities.pass * Skill.lerpLevel(minAddRatioConfig, maxAddRatioConfig, level)
        end,
    }
end

return BlauwbrugBrainEx1

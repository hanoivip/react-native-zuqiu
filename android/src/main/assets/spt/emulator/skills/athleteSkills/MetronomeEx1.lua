local Skill = import("../Skill")
local Metronome = import("./Metronome")

local MetronomeEx1 = class(Metronome, "MetronomeEx1")
MetronomeEx1.id = "B03_1"
MetronomeEx1.alias = "节拍器"

local minProbability = 1
local maxProbability = 1
-- Buff额外加成(节拍器，众志成城，冲锋号角)百分比
local minAddConfig = 0.5
local maxAddConfig = 0.5

function MetronomeEx1:ctor(level)
    Metronome.ctor(self, level)
    self.ex1Probability = Skill.lerpLevel(minProbability, maxProbability, level)
    self.ex1Addratio = Skill.lerpLevel(minAddConfig, maxAddConfig, level)

    self.ex1Buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return false
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.ex1Addratio
        end,
        persistent = true,
    }

end

return MetronomeEx1
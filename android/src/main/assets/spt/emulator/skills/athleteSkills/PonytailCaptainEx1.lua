local Skill = import("../Skill")
local PonytailCaptain = import("./PonytailCaptain")
local DefenseCommandorEx1 = import("./DefenseCommandorEx1")

local PonytailCaptainEx1 = class(DefenseCommandorEx1, "PonytailCaptainEx1")
PonytailCaptainEx1.id = "E04_A_1"
PonytailCaptainEx1.alias = "Ex马尾统帅"

local minAddConfig = 0.08
local maxAddConfig = 0.08

function PonytailCaptainEx1:ctor(level)
    if PonytailCaptain.initConfig then
        PonytailCaptain:initConfig(self)
    end
    DefenseCommandorEx1.ctor(self, level)
    self.exa1AddRatio = Skill.lerpLevel(minAddConfig, maxAddConfig, level)
    self.exa1Buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return false
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.ex1AddRatio
        end,
        persistent = true,
    }
end

function PonytailCaptainEx1:enterField(athlete)
    DefenseCommandorEx1.enterField(self, athlete)
end

return PonytailCaptainEx1

local Skill = import("../Skill")
local MidfieldMaestros = import("./MidfieldMaestros")
local MetronomeEx1 = import("./MetronomeEx1")

local MidfieldMaestrosEx1 = class(MetronomeEx1, "MidfieldMaestrosEx1")
MidfieldMaestrosEx1.id = "B03_A_1"
MidfieldMaestrosEx1.alias = "中场指挥家"

--debuff失效时间
local durationConfig = 16

function MidfieldMaestrosEx1:ctor(level)
    if MidfieldMaestros.initConfig then
        MidfieldMaestros:initConfig(self)
    end
    MetronomeEx1.ctor(self, level)

    self.exa1Buff = {
        skill = self,
        remark = "debuffBlocked",
        duration = durationConfig,
        removalCondition = function(remainingTime, caster, receiver)
            return math.cmpf(remainingTime, 0) <= 0
        end,
    }
end

return MidfieldMaestrosEx1
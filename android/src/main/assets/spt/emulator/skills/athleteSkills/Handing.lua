local Skill = import("../Skill")

local Handing = class(Skill, "Handing")
Handing.id = "E05"
Handing.alias = "手控球"

local minProbability = 1
local maxProbability = 1
local minAddSaveConfig = 0.55
local maxAddSaveConfig = 5.5

function Handing:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.remainingCooldown = 0
    self.probability = Skill.lerpLevel(minProbability, maxProbability, level)
    self.addSaveConfig = Skill.lerpLevel(minAddSaveConfig, maxAddSaveConfig, level)
end

return Handing
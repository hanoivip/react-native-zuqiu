local Skill = import("../Skill")

local TopStudentOnField = class(Skill, "TopStudentOnField")
TopStudentOnField.id = "LR_GCHIELLINI2"
TopStudentOnField.alias = "球场学霸"

-- 受影响范围
local influenceDistanceConfig = 18
-- 干扰配置
local minInfluenceConfig = 0.5
local maxInfluenceConfig = 0.5
local minAddConfig = 0.1
local maxAddConfig = 0.1

function TopStudentOnField:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.remainingCooldown = 0
    self.influenceDistance = influenceDistanceConfig
    self.influence = Skill.lerpLevel(minInfluenceConfig, maxInfluenceConfig, level)
    self.addRatio = Skill.lerpLevel(minAddConfig, maxAddConfig, level)

    self.buffSign = {
        skill = self,
        remark = "buffSign",
        removalCondition = function(remainingTime, caster, receiver)
            return false
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio
        end,
        persistent = true
    }
end

return TopStudentOnField
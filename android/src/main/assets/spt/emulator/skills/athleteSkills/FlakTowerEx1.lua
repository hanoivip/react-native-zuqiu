local Skill = import("../Skill")
local FlakTower = import("./FlakTower")

local FlakTowerEx1 = class(FlakTower, "FlakTowerEx1")
FlakTowerEx1.id = "A05_1"
FlakTowerEx1.alias = "防空塔"

-- 头球干扰配置
local minHeadBallInfluenceConfig = 0.55
local maxHeadBallInfluenceConfig = 0.65
-- 凌空干扰配置
local minVolleyShootInfluenceConfig = 0.55
local maxVolleyShootInfluenceConfig = 0.65
-- 头球干扰概率
local minHeadBallInfluenceProbabilityConfig = 0.6
local maxHeadBallInfluenceProbabilityConfig = 0.6
-- 凌空干扰概率
local minVolleyShootInfluenceProbabilityConfig = 0.6
local maxVolleyShootInfluenceProbabilityConfig = 0.6
-- 递减比例
local decreaseRateConfig = 0.5
-- 受影响范围
local influenceDistanceConfig = 18

function FlakTowerEx1:ctor(level)
    FlakTower.ctor(self, level)
    self.decreaseRate = decreaseRateConfig
    self.headBallInfluence = Skill.lerpLevel(minHeadBallInfluenceConfig, maxHeadBallInfluenceConfig, level)
    self.volleyShootInfluence = Skill.lerpLevel(minVolleyShootInfluenceConfig, maxVolleyShootInfluenceConfig, level)    
    self.headBallInfluenceProbability = Skill.lerpLevel(minHeadBallInfluenceProbabilityConfig, maxHeadBallInfluenceProbabilityConfig, level)
    self.volleyShootInfluenceProbability = Skill.lerpLevel(minVolleyShootInfluenceProbabilityConfig, maxVolleyShootInfluenceProbabilityConfig, level)
    self.influenceDistance = influenceDistanceConfig   
end

return FlakTowerEx1
local GreenswardIntroduceType = require("ui.controllers.greensward.introduce.GreenswardIntroduceType")
local AdventureRegion = require("data.AdventureRegion")
local GreenswardIntroduceModel = require("ui.models.greensward.introduce.GreenswardIntroduceModel")

local GreenswardSeasonRewardModel = class(GreenswardIntroduceModel, "GreenswardSeasonRewardModel")

local IntroPath = {}
IntroPath.completeReward = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/SeasonReward/CompleteReward.prefab"
IntroPath.allReward = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/SeasonReward/AllRewardPage.prefab"
IntroPath.playTips = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Introduce/PlayTips.prefab"

function GreenswardSeasonRewardModel:ctor()
    GreenswardSeasonRewardModel.super.ctor(self)
    self.introduceTab = nil -- 奖励类型
    self.regionTag = nil -- 战区选择的纪录
end

function GreenswardSeasonRewardModel:InitWithProtocol(data)
    self.data = data
    self.adventureReward = data.rewardStatic
    self.adventureSeasonReward = data.AdventureSeasonReward
    self.introduceTab = ""
    self.regionTag = {}
    self:SetRegion(tostring(self.data.region))
end

function GreenswardSeasonRewardModel:GetStatusData()
    return self:GetGreenswardBuildModel(), self:GetTab(), self:GetRegion()
end

function GreenswardSeasonRewardModel:SetTab(introduceTab)
    self.introduceTab = introduceTab or GreenswardIntroduceType.CompleteReward
    -- 测试需求，每次切换tab都切到自己的战区
    -- 所以每次切换tab，将战区的重置
    self.regionTag = self:GetMyRegion()
end

function GreenswardSeasonRewardModel:GetTab()
    return self.introduceTab or GreenswardIntroduceType.CompleteReward
end

function GreenswardSeasonRewardModel:SetRegion(regionTag)
    self.regionTag = regionTag or self:GetMyRegion()
end

function GreenswardSeasonRewardModel:GetRegion()
    return self.regionTag ~= nil and self.regionTag or self:GetMyRegion()
end

function GreenswardSeasonRewardModel:GetAdventureRewardByRegionID(regionID)
    local myRegion = self:GetMyRegion()
    regionID = tostring(regionID)
    myRegion = tostring(myRegion)
    local rewardRecord = self.data.rewardRecord
    local adventureReward = self:GetAdventureReward()
    local result = {}
    local isInMyRegion = regionID == myRegion
    local moraleReward = self:GetMoraleReward()
    for i, v in pairs(adventureReward[regionID]) do
        local index = tonumber(i)
        v.floorID = index
        result[index] = v
        if isInMyRegion then
            v.completeData = rewardRecord[i]
        end
        v.isInMyRegion = isInMyRegion
        v.moraleReward = moraleReward
    end
    table.sort(result, function(a, b) return a.floorID < b.floorID end)
    return result
end

function GreenswardSeasonRewardModel:GetPrefabPathByTag(tag)
    return IntroPath[tag] or ""
end

function GreenswardSeasonRewardModel:GetTopFloor()
    return self.data.topFl
end

function GreenswardSeasonRewardModel:GetMyRegion()
    return self.data.region
end

function GreenswardSeasonRewardModel:GetRegionName()
    return self.buildModel:GetRegionName()
end

-- 获得赛季开始时历史最高战力
function GreenswardSeasonRewardModel:GetInitialPower()
    return self.data.power
end

function GreenswardSeasonRewardModel:RefreshData(data)
    local rewardRecord = data.rewardRecord
    for i, v in pairs(rewardRecord) do
        self.data.rewardRecord[i].rate = v.rate
        self.data.rewardRecord[i].st = v.st
        EventSystem.SendEvent("AllRewardItemView_Refresh", i, self.data.rewardRecord[i])
    end
end

-- 获得战力在战区中的位置
-- @return : 一个小数，百分比请乘100
function GreenswardSeasonRewardModel:GetPowerLoc()
    local myRegion = tostring(self:GetMyRegion())
    local power = self:GetInitialPower()
    local config = AdventureRegion[myRegion]
    return (power - config.powerLow) / (config.powerHigh - config.powerLow)
end

-- 获得每层通关士气奖励
-- @return [low]: 战力在当前战区所占百分比区间下限
-- @return [high]: 战力在当前战区所占百分比区间上限，为nil表示无上限
-- @return [morale]: 战力在当前战区当前百分比区间应奖励的数值，每层目前配置一样
function GreenswardSeasonRewardModel:GetMoraleReward()
    local powerPer = self:GetPowerLoc() * 100
    local stageMorales = self:GetCompleteRewardMoraleItems()
    local morale = 0
    local low = 0
    local high = 0
    for idx, config in ipairs(stageMorales) do
        -- 左开右闭
        if powerPer > config.low and (config.high == nil or powerPer <= config.high) then
            low = config.low
            high = config.high
            morale = config.morale
            break
        end
    end
    return morale, low, high
end

return GreenswardSeasonRewardModel

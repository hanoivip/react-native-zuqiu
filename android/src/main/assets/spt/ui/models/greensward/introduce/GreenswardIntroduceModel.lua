local GreenswardIntroduceType = require("ui.controllers.greensward.introduce.GreenswardIntroduceType")
local AdventureBase = require("data.AdventureBase")
local AdventureRegion = require("data.AdventureRegion")
local Model = require("ui.models.Model")

local GreenswardIntroduceModel = class(Model, "GreenswardIntroduceModel")

function GreenswardIntroduceModel:ctor()
    GreenswardIntroduceModel.super.ctor(self)
    self.introduceTab = nil -- 奖励类型
    self.regionTag = nil -- 战区选择的纪录
end

function GreenswardIntroduceModel:Init()
    GreenswardIntroduceModel.super.Init(self)
end

function GreenswardIntroduceModel:InitWithProtocol(data)
    self.data = data
    self.introduceTab = ""
    self.adventureReward = data.AdventureReward
    self.adventureSeasonReward = data.AdventureSeasonReward
end

function GreenswardIntroduceModel:GetStatusData()
    return self:GetGreenswardBuildModel(), self:GetTab(), self:GetRegion(), self:GetTabStates()
end

function GreenswardIntroduceModel:SetGreenswardBuildModel(greenswardBuildModel)
    self.buildModel = greenswardBuildModel
end

function GreenswardIntroduceModel:GetGreenswardBuildModel()
    return self.buildModel
end

function GreenswardIntroduceModel:SetTabAndRegion(introduceTab, regionTag)
    self:SetTab(introduceTab)
    self:SetRegion(regionTag)
end

function GreenswardIntroduceModel:SetTab(introduceTab)
    self.introduceTab = introduceTab or GreenswardIntroduceType.PlayIntroduce
    -- 测试需求，每次切换tab都切到自己的战区
    -- 所以每次切换tab，将战区的重置
    self.regionTag = tostring(self:GetMyRegion())
end

function GreenswardIntroduceModel:GetTab()
    return self.introduceTab or GreenswardIntroduceType.PlayIntroduce
end

function GreenswardIntroduceModel:SetRegion(regionTag)
    self.regionTag = regionTag or self:GetMyRegion()
end

function GreenswardIntroduceModel:GetRegion()
    return self.regionTag ~= nil and self.regionTag or self:GetMyRegion()
end

function GreenswardIntroduceModel:SetTabStates(tabStates)
    self.tabStates = tabStates
end

function GreenswardIntroduceModel:GetTabStates()
    return self.tabStates
end

function GreenswardIntroduceModel:GetMyRegion()
    return self.buildModel:GetRegion()
end

function GreenswardIntroduceModel:GetAdventureReward()
    return self.adventureReward
end

function GreenswardIntroduceModel:GetAdventureRewardByRegionID(regionID)
    regionID = tostring(regionID)
    local adventureReward = self:GetAdventureReward()
    local result = {}
    for i, v in pairs(adventureReward[regionID]) do
        v.floorID = tonumber(i)
        result[tonumber(i)] = v
    end
    table.sort(result, function(a, b) return a.floorID < b.floorID end)
    return result
end

function GreenswardIntroduceModel:GetAllRegion()
    local result = {}
    for i, v in pairs(AdventureRegion) do
        local index = tonumber(i)
        v.regionID = i
        result[index] = v
    end
    return result
end

function GreenswardIntroduceModel:GetAdventureSeasonReward()
    return self.adventureSeasonReward
end

function GreenswardIntroduceModel:GetAdventureSeasonRewardByRegionID(regionID)
    regionID = tostring(regionID)
    local seasonReward = self:GetAdventureSeasonReward()
    local result = {}
    for i, v in pairs(seasonReward[regionID]) do
        table.insert(result, v)
    end
    table.sort(result, function(a, b) return a.rankID < b.rankID end)
    return result
end

-- 获得通关奖励每层士气奖励的列表显示数组
--{
    -- {
    --     high = 30,
    --     low = 0,
    --     morale = 100,
    -- },
    -- {
    --     high = 60,
    --     low = 30,
    --     morale = 120,
    -- },
--}
function GreenswardIntroduceModel:GetCompleteRewardMoraleItems()
    local stageMoraleConfig = AdventureBase["1"].stageMorale
    local stageMorales = {}
    for range_high, morale in pairs(stageMoraleConfig) do
        local moraleReward = {}
        moraleReward.high = tonumber(range_high)
        moraleReward.morale = tonumber(morale)
        table.insert(stageMorales, moraleReward)
    end
    table.sort(stageMorales, function(a, b)
        return a.high < b.high
    end)
    -- 修正成 low <= var <= high
    for idx, moraleReward in ipairs(stageMorales) do
        if stageMorales[idx - 1] == nil then -- 第一条，给low赋值-1
            moraleReward.low = -1
        elseif stageMorales[idx + 1] == nil then -- 最后一条，>=此条都按最高算奖励
            moraleReward.low = stageMorales[idx - 1].high
            moraleReward.high = nil
        else
            moraleReward.low = stageMorales[idx - 1].high
        end
    end
    return stageMorales
end

return GreenswardIntroduceModel

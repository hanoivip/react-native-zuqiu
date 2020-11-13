local PeakReward = require("data.PeakReward")
local PeakRankReward = require("data.PeakRankReward")
local PeakRewardNum = require("data.PeakRewardNum")
local Model = require("ui.models.Model")

local PeakRuleModel = class(Model)

function PeakRuleModel:ctor()
    PeakRuleModel.super.ctor(self)
    self.staticData = {}
    self:InitStaticData()
end

function PeakRuleModel:InitStaticData()
    self.staticData.peakRewardNum = PeakRewardNum
    local peakRankReward = {}
    for k, v in pairs(PeakRankReward) do
        table.insert(peakRankReward, v)
    end
    table.sort(peakRankReward, function (a, b)
        return a.low < b.low
    end)
    self.staticData.peakRankReward = peakRankReward
end

function PeakRuleModel:GetPeakRewardData()
    return self.staticData.peakRewardNum or {}
end

function PeakRuleModel:GetPeakScoreData()
    return PeakReward or {}
end


function PeakRuleModel:GetPeakRankRewardData()
    return self.staticData.peakRankReward or {}
end

return PeakRuleModel
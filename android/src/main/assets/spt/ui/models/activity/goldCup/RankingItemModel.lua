local RewardItemViewModel = require("ui.models.quest.RewardItemViewModel")
local RankingItemModel = class(Model, "RankingItemModel")

function RankingItemModel:ctor(data)
    assert(type(data) == "table", "data error!!!")
    self.itemData = data
end

function RankingItemModel:IsPlayerSatisfyCondition()
    local isPlayerSatisfyCondition = next(self.itemData) and self.itemData.pid
    return isPlayerSatisfyCondition
end

function RankingItemModel:GetPlayerRankAndNameStr()
    local rank = self:GetPlayerRank()
    local name = self:GetPlayerName()
    local str = rank .. ". " .. name
    return str
end

function RankingItemModel:GetPlayerName()
    local name = self.itemData.name or ""
    return name
end

function RankingItemModel:GetPlayerRank()
    local rank = self.itemData.rank or "-"
    return rank
end

function RankingItemModel:GetDistrictID()
    local sid = tostring(self.itemData.sid or 1)
    return sid
end

function RankingItemModel:GetPointsValue()
    local points = tostring(self.itemData.score or 0)
    return points
end

return RankingItemModel
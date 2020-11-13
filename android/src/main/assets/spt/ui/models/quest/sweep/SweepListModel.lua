local Model = require("ui.models.Model")
local RewardUpdateCacheModel = require("ui.models.common.RewardUpdateCacheModel")
local ItemsMapModel = require("ui.models.ItemsMapModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CustomEvent = require("ui.common.CustomEvent")

local SweepListModel = class(Model)

function SweepListModel:ctor(data)
    SweepListModel.super.ctor(self)
    local playerInfoModel = PlayerInfoModel.new()
    playerInfoModel:LockLevelUp()
    -- 更新奖励
    self.rewardUpdateCacheModel = RewardUpdateCacheModel.new()
    self.rewardUpdateCacheModel:UpdateCache(data.reward.total)
    -- 更新花费
    self.itemsMapModel = ItemsMapModel.new()
    self.itemsMapModel:UpdateFromReward(data.cost)

    if data.reward.total.d and tonumber(data.reward.total.d) > 0 then
        CustomEvent.GetDiamond("2", tonumber(data.reward.total.d))
    end
    if data.reward.total.m and tonumber(data.reward.total.m) > 0 then
        CustomEvent.GetMoney("2", tonumber(data.reward.total.m))
    end
    if data.info.sp then
        playerInfoModel:SetStrength(data.info.sp)
    end
    self.cacheData = data.reward
end

function SweepListModel:GetListData()
    return self.cacheData.list
end

function SweepListModel:IsHasCurrItem(id)
    for k, v in pairs(self.cacheData.list) do
        for k1, v1 in pairs(v) do
            if k1 == "eqs" or k1 == "equipPiece" then
                for k2, v2 in pairs(v1) do
                    if id == v2.id then
                        return true
                    end
                end
            end
        end
    end
    return false
end

function SweepListModel:GetTotalData()
    return self.cacheData.total
end

return SweepListModel

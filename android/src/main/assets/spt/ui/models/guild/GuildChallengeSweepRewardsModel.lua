local Model = require("ui.models.Model")
local RewardUpdateCacheModel = require("ui.models.common.RewardUpdateCacheModel")
local ItemsMapModel = require("ui.models.ItemsMapModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CustomEvent = require("ui.common.CustomEvent")

local GuildChallengeSweepRewardsModel = class(Model)

function GuildChallengeSweepRewardsModel:ctor(data)
    GuildChallengeSweepRewardsModel.super.ctor(self)
    local playerInfoModel = PlayerInfoModel.new()
    -- 更新奖励
    self.rewardUpdateCacheModel = RewardUpdateCacheModel.new()
    self.rewardUpdateCacheModel:UpdateCache(data.contents)
    -- 更新花费
    self.itemsMapModel = ItemsMapModel.new()
    self.itemsMapModel:UpdateFromReward(data.cost)
    self.cacheData = data

    if data.cost.sp then
        playerInfoModel:SetStrength(data.cost.sp)
    end
end

function GuildChallengeSweepRewardsModel:GetRewardData()
    return self.cacheData
end

return GuildChallengeSweepRewardsModel

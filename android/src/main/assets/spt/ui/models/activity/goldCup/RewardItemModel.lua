local RewardItemViewModel = require("ui.models.quest.RewardItemViewModel")
local RewardItemModel = class(RewardItemViewModel, "RewardItemModel")

function RewardItemModel:ctor(data)
    assert(type(data) == "table", "data error!!!")
    RewardItemModel.super.ctor(self, data)
    self.itemData = data
end

function RewardItemModel:GetRankStr()
    local rankHigh = self.itemData.rankHigh
    local rankLow = self.itemData.rankLow
    local affix = rankHigh .. "-" .. rankLow
    if rankHigh == rankLow then
        affix = rankHigh
    end
    local str = lang.transstr("guildwar_rank", affix)
    return str
end

function RewardItemModel:GetItemIndex()
    local index = self.itemData.index or 0
    return index
end

function RewardItemModel:GetRewardContents()
    local rewardContents = self.itemData.contents or {}
    return rewardContents
end

return RewardItemModel
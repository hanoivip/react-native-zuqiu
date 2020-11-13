local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local GuildRankingRewardItemModel = require("ui.models.activity.mascotPresent.GuildRankingRewardItemModel")
local GuildRewardScrollView = class(LuaScrollRectExSameSize)

function GuildRewardScrollView:ctor()
    GuildRewardScrollView.super.ctor(self)

    self.scrollRect = self.___ex.scrollRect
end

function GuildRewardScrollView:start()
end

function GuildRewardScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Activties/MascotPresent/MPGuildRankingRewardItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function GuildRewardScrollView:resetItem(spt, index)
    local itemModel = GuildRankingRewardItemModel.new(self.itemDatas[index])
    spt:InitView(itemModel, self.scrollRect, self.activityModel)  
    self:updateItemIndex(spt, index)
end

function GuildRewardScrollView:InitView(activityModel)
    self.activityModel = activityModel
    local rewardList = self.activityModel:GetGuildRankingRewardList()
    self:refresh(rewardList)
end

return GuildRewardScrollView

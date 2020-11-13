local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local GuildRankingItemModel = require("ui.models.activity.mascotPresent.GuildRankingItemModel")
local GuildRankingScrollView = class(LuaScrollRectExSameSize)

function GuildRankingScrollView:ctor()
    self.noRankingItemViewObj = self.___ex.noRankingItemViewObj
    GuildRankingScrollView.super.ctor(self)
end

function GuildRankingScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Activties/MascotPresent/GuildRankingItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function GuildRankingScrollView:resetItem(spt, index)
    local itemModel = GuildRankingItemModel.new(self.data[index])
    spt:InitView(itemModel, self.activityModel)
    spt.onBtnDetailClick = function()
        EventSystem.SendEvent("GuildRankingItem_Detail", itemModel:GetGid())
    end
end

function GuildRankingScrollView:InitView(mascotPresentModel)
    self.activityModel = mascotPresentModel
    local rankingList = self.activityModel:GetGuildRankingList()
    assert(type(rankingList) == "table", "data error!")

    local hasRankingItem = next(rankingList)
    GameObjectHelper.FastSetActive(self.noRankingItemViewObj, not hasRankingItem)
    if not hasRankingItem then return end

    self.data = rankingList
    self:refresh(rankingList)
end

return GuildRankingScrollView
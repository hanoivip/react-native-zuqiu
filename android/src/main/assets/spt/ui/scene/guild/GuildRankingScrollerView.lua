local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local GuildRankingItemModel = require("ui.models.guild.GuildRankingItemModel")
local GuildRankingScrollerView = class(LuaScrollRectExSameSize)

function GuildRankingScrollerView:ctor()
    GuildRankingScrollerView.super.ctor(self)
end

function GuildRankingScrollerView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildRankingItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function GuildRankingScrollerView:resetItem(spt, index)
    local itemModel = GuildRankingItemModel.new(self.data[index])
    spt:InitView(itemModel)
    spt.onBtnDetailClick = function()
        EventSystem.SendEvent("GuildRankingItem_Detail", itemModel:GetGid())
    end
end

function GuildRankingScrollerView:InitView(data)
    self.data = data
    self:refresh(self.data)
end

return GuildRankingScrollerView
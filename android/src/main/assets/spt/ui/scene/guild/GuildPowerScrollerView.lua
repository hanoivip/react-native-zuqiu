local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local GuildPowerItemModel = require("ui.models.guild.GuildPowerItemModel")
local GuildPowerScrollerView = class(LuaScrollRectExSameSize)

function GuildPowerScrollerView:ctor()
    GuildPowerScrollerView.super.ctor(self)
end

function GuildPowerScrollerView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildPowerItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function GuildPowerScrollerView:resetItem(spt, index)
    local itemModel = GuildPowerItemModel.new(self.data[index])
    spt:InitView(itemModel)
    spt.onBtnDetailClick = function()
        EventSystem.SendEvent("GuildRankingItem_Detail", itemModel:GetGid())
    end
end

function GuildPowerScrollerView:InitView(data)
    self.data = data
    self:refresh(self.data)
end

return GuildPowerScrollerView
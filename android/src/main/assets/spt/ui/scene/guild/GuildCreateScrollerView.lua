local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local GuildLogoItemModel = require("ui.models.guild.GuildLogoItemModel")
local GuildCreateScrollerView = class(LuaScrollRectExSameSize)

function GuildCreateScrollerView:ctor()
    GuildCreateScrollerView.super.ctor(self)
end

function GuildCreateScrollerView:start()
end

function GuildCreateScrollerView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildLogoItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function GuildCreateScrollerView:resetItem(spt, index)
    local itemModel = GuildLogoItemModel.new(self.data[index])
    spt:InitView(itemModel)
    spt.onIconClickFunc = function() self:onIconClickFunc(itemModel:GetIndex()) end
    self:updateItemIndex(spt, index)
end

function GuildCreateScrollerView:InitView(data)
    self.data = data
    self:refresh(self.data)
end

function GuildCreateScrollerView:Clear()
    self:removeAll()
end

function GuildCreateScrollerView:onIconClickFunc(index)
    EventSystem.SendEvent("Guild_LogoItemClick", index)
end

return GuildCreateScrollerView
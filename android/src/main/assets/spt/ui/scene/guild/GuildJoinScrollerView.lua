local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local GuildJoinItemModel = require("ui.models.guild.GuildJoinItemModel")
local GuildJoinScrollerView = class(LuaScrollRectExSameSize)

function GuildJoinScrollerView:ctor()
    GuildJoinScrollerView.super.ctor(self)
end

function GuildJoinScrollerView:start()
end

function GuildJoinScrollerView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildJoinItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function GuildJoinScrollerView:resetItem(spt, index)
    local itemModel = GuildJoinItemModel.new(self.data[index])
    spt:InitView(itemModel)
    spt.clickReceive = function()
        self:OnReceiveClick(itemModel)
    end
    self:updateItemIndex(spt, index)
end

function GuildJoinScrollerView:InitView(data)
    self.data = data
    self:refresh(self.data)
end

function GuildJoinScrollerView:OnReceiveClick(itemModel)
    EventSystem.SendEvent("GuildJoinScrollerView_ItemClick", itemModel)
end

return GuildJoinScrollerView
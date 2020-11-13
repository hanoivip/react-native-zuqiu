local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local GuildLogItemModel = require("ui.models.guild.GuildLogItemModel")
local GuildLogScrollerView = class(LuaScrollRectExSameSize)

function GuildLogScrollerView:ctor()
    GuildLogScrollerView.super.ctor(self)
end

function GuildLogScrollerView:start()
end

function GuildLogScrollerView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildLogItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function GuildLogScrollerView:resetItem(spt, index)
    local itemModel = GuildLogItemModel.new(self.data[index])
    spt:InitView(itemModel)
end

function GuildLogScrollerView:InitView(data)
    self.data = data
    self:refresh(self.data)
end

return GuildLogScrollerView
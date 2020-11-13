local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local ChatPacketItemModel = require("ui.models.chat.ChatPacketItemModel")
local ChatPacketScrollerView = class(LuaScrollRectExSameSize)

function ChatPacketScrollerView:ctor()
    ChatPacketScrollerView.super.ctor(self)
end

function ChatPacketScrollerView:start()
end

function ChatPacketScrollerView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Chat/Prefab/ChatPacketItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function ChatPacketScrollerView:resetItem(spt, index)
    local itemModel = ChatPacketItemModel.new(self.data[index])
    spt:InitView(itemModel)
    self:updateItemIndex(spt, index)
end

function ChatPacketScrollerView:InitView(data)
    self.data = data
    self:refresh(self.data)
end

return ChatPacketScrollerView
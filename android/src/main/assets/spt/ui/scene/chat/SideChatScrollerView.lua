local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local SidePlayerItemModel = require("ui.models.chat.SidePlayerItemModel")
local SideChatScrollerView = class(LuaScrollRectExSameSize)

function SideChatScrollerView:ctor()
    SideChatScrollerView.super.ctor(self)
end

function SideChatScrollerView:start()
end

function SideChatScrollerView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Chat/Prefab/SidePlayerItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function SideChatScrollerView:resetItem(spt, index)
    local itemModel = SidePlayerItemModel.new(self.data[index])
    spt:InitView(itemModel)
    spt.clickReceive = function()
        self:OnReceiveClick(itemModel:GetPid(), itemModel:GetSid())
    end
    spt.clickClose = function()
        self:OnCloseClick(itemModel:GetPid(), itemModel:GetSid())
    end
    self:updateItemIndex(spt, index)
end

function SideChatScrollerView:InitView(data)
    self.data = data
    self:refresh(self.data)
end

function SideChatScrollerView:RefreshView(data)
    for i = 1, #data do
        self:addItem(data[i])
    end
end

function SideChatScrollerView:OnReceiveClick(pid, sid)
    EventSystem.SendEvent("SideChatScroll_ClickReceiced", pid, sid)
end

function SideChatScrollerView:OnCloseClick(pid, sid)
    EventSystem.SendEvent("SideChatScroll_RemoveItem", pid, sid)
end



return SideChatScrollerView
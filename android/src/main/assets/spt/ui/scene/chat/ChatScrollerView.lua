local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Image = UI.Image
local Text = UI.Text
local Object = UnityEngine.Object
local GameObject = UnityEngine.GameObject
local Vector2 = UnityEngine.Vector2
local ChatItemModel = require("ui.models.chat.ChatItemModel")
local ChatTipDialogModel = require("ui.models.chat.ChatTipDialogModel")
local CHAT_TYPE = require("ui.controllers.chat.CHAT_TYPE")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")

local LuaScrollRectEx = require("ui.control.scroll.LuaScrollRectEx")

local ChatScrollerView = class(LuaScrollRectEx)

function ChatScrollerView:ctor()
    self.content = self.___ex.content
    self.cScrollRect = self.___ex.cScrollRect
    self.super.ctor(self)
    self.currentChatType = nil
    self.itemDatas = {}
    self.scrollToEnd = true
    self.sendToEnd = false
end

function ChatScrollerView:InitView(chatMsgList, currentChatType)
    self.itemDatas = {}
    self.currentChatType = currentChatType
    for i = 1, #chatMsgList do
        local chatItemModel = ChatItemModel.new(chatMsgList[i])
        chatItemModel.currentChatType = currentChatType
        table.insert(self.itemDatas, chatItemModel)
    end
    self:refresh()    
    self:coroutine(function()
        coroutine.yield(UnityEngine.WaitForSeconds(0.01))
        if #self.itemDatas > 0 then
            self:scrollToCellImmediate(#self.itemDatas)
            EventSystem.SendEvent("ChatScrollerView_CalculateCount", -1)
        end
    end)
end

function ChatScrollerView:RefreshView(chatMsgList, currentChatType)
    self.currentChatType = currentChatType
    if not chatMsgList or #chatMsgList <= 0 then
        return 
    end
    for i = 1, #chatMsgList do
        local chatItemModel = ChatItemModel.new(chatMsgList[i])
        chatItemModel.currentChatType = currentChatType
        self:addItem(chatItemModel)
    end

    if not self.scrollToEnd then
        EventSystem.SendEvent("ChatScrollerView_CalculateCount", #chatMsgList)
    end

    self:coroutine(function()
        coroutine.yield(UnityEngine.WaitForSeconds(0.01))
        if #self.itemDatas > 0 and (self.scrollToEnd or self.sendToEnd) then
            self:scrollToCellImmediate(#self.itemDatas)
            self.firstToEnd = false
            self.sendToEnd = false
        end
    end)
end

function ChatScrollerView:start()
    self:RegOnScrollPosChangeFunc()
end

function ChatScrollerView:GetVisibleItemIndex()
    return self:getStartVisibleItemIndex()
end

function ChatScrollerView:RegOnScrollPosChangeFunc()
    self:regOnScrollPositionChanged(function()
        if #self.itemDatas > 0 then
            if self:getEndVisibleItemIndex() == #self.itemDatas - 1 then
                self.scrollToEnd = true
                EventSystem.SendEvent("ChatScrollerView_CalculateCount", -1)
            else
                self.scrollToEnd = false
            end
            EventSystem.SendEvent("ScrollPos_SetNewPacketPanel")
        end
    end)
end

function ChatScrollerView:ScrollToIndex(index)
    self:scrollToCell(index)
end

function ChatScrollerView:SetSendToEndState()
    self.sendToEnd = true
end

function ChatScrollerView:BuildPage()
    self:refresh()
end

function ChatScrollerView:ResetItem(spt, index)
    spt.gameObject.transform.sizeDelta = Vector2(self.gameObject.transform.sizeDelta.x, self.itemDatas[index]:GetTheTextHeight())
    spt:InitView(self.itemDatas[index])
    spt.logoClickFunc = function()
        local pid = self.itemDatas[index]:GetSender().pid
        local sid = self.itemDatas[index]:GetSender().sid
        PlayerDetailCtrl.ShowPlayerDetailView(function() return req.friendsDetail(pid, sid) end, pid, sid)
    end
    if self.itemDatas[index]:GetForm() == 3 then
        spt.packetcontentClick = function()
            EventSystem.SendEvent("ChatItem_ClickPacket", self.itemDatas[index]:GetMessage()._id, "signRedPacket")
        end
    elseif self.itemDatas[index]:GetForm() == 4 then
        spt.packetcontentClick = function()
            EventSystem.SendEvent("ChatItem_ClickPacket", self.itemDatas[index]:GetMessage()._id, "itemRedPacket")
        end
    end
end

function ChatScrollerView:getItemTag(index)
    if self.itemDatas[index]:GetIsSelf() then
        if self.itemDatas[index]:GetForm() then
            if self.itemDatas[index]:GetForm() == 1 then
                return "PrefabMySelf"
            else
                return "PrefabPacketMySelf"
            end
        else
            return "PrefabMySelf"
        end
    else
        if self.itemDatas[index]:GetForm() then
            if self.itemDatas[index]:GetForm() == 1 then
                return "PrefabOther"
            else
                return "PrefabPacketOther"
            end
        else
            return "PrefabOther"
        end
    end
end

function ChatScrollerView:createItemByTagPrefabPacketMySelf()
    local path = "Assets/CapstonesRes/Game/UI/Scene/Chat/Prefab/ChatItemPacketMyself.prefab"
    local node = Object.Instantiate(res.LoadRes(path, GameObject))
    return node
end

function ChatScrollerView:createItemByTagPrefabPacketOther()
    local path = "Assets/CapstonesRes/Game/UI/Scene/Chat/Prefab/ChatItemPacketOther.prefab"
    local node = Object.Instantiate(res.LoadRes(path, GameObject))
    return node
end

function ChatScrollerView:resetItemByTagPrefabPacketMySelf(spt, index)
    self:ResetItem(spt, index)
end

function ChatScrollerView:resetItemByTagPrefabPacketOther(spt, index)
    self:ResetItem(spt, index)
end

function ChatScrollerView:createItemByTagPrefabOther()
    local path = "Assets/CapstonesRes/Game/UI/Scene/Chat/Prefab/ChatItemOther.prefab"
    if self.currentChatType == CHAT_TYPE.PLAYER then
        path = "Assets/CapstonesRes/Game/UI/Scene/Chat/Prefab/SideChatItemOther.prefab"
    end
    local node = Object.Instantiate(res.LoadRes(path, GameObject))
    return node
end

function ChatScrollerView:resetItemByTagPrefabOther(spt, index)
    self:ResetItem(spt, index)
end

function ChatScrollerView:createItemByTagPrefabMySelf()
    local path = "Assets/CapstonesRes/Game/UI/Scene/Chat/Prefab/ChatItemMySelf.prefab"
    if self.currentChatType == CHAT_TYPE.PLAYER then
        path = "Assets/CapstonesRes/Game/UI/Scene/Chat/Prefab/SideChatItemMySelf.prefab"
    end
    local node = Object.Instantiate(res.LoadRes(path, GameObject))
    return node
end

function ChatScrollerView:resetItemByTagPrefabMySelf(spt, index)
    self:ResetItem(spt, index)
end

return ChatScrollerView

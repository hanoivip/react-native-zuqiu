local BaseCtrl = require("ui.controllers.BaseCtrl")
local ChatMainModel = require("ui.models.chat.ChatMainModel")
local DialogManager = require("ui.control.manager.DialogManager")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CHAT_TYPE = require("ui.controllers.chat.CHAT_TYPE")
local CostDiamondHelper = require("ui.common.CostDiamondHelper")
local UnityEngine = clr.UnityEngine

local ChatMainCtrl = class(BaseCtrl)

ChatMainCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Chat/Prefab/Chat.prefab"

function ChatMainCtrl:Init(ChatType)
    self.currentChatType = ChatType
    self.chatMainModel = ChatMainModel.new()
    self.playerInfoModel = PlayerInfoModel.new()

    self.view.sendFunction = function()
        clr.coroutine(function()
            local str = self.view:GetInputText()
            if not self:CheckSendMsg(str) then return end
            if self.currentChatType == CHAT_TYPE.WORLD then
                local count = self.chatMainModel:GetWorldFreeCount()
                local sendFunc = function()
                    clr.coroutine(function()
                        local resp = req.sendWorldMessage(str, nil, nil, true)
                        if api.success(resp) then
                            self.view:ResetInputText()
                            local data = resp.val
                            self.view:SetSendToEndState(self.currentChatType)
                            self.chatMainModel:SetWorldLimitTime(60)
                            self.chatMainModel:InitWithProtocol(data, self.currentChatType)
                            self:InitLimitText()
                            self:RefreshChatView()
                            if type(data.cost) == "table" then
                                if data.cost["type"] == "d" then
                                    self.playerInfoModel:AddDiamond(-1 * data.cost.num)
                                end
                            end
                            if count > 0  then
                                DialogManager.ShowToast(lang.transstr("chat_freeSuccess", data.free))
                            end
                        else
                            local data = resp.val
                            DialogManager.ShowToastByLang(data)
                        end
                    end)
                end
                if count > 0 then
                    sendFunc()
                else
                    DialogManager.ShowConfirmPop(lang.transstr("chat_sendTitle"), lang.transstr("chat_sendContent"), function()
                        sendFunc()
                    end)
                end
               
            elseif self.currentChatType == CHAT_TYPE.PLAYER then
                local pid = self.chatMainModel:GetCurrentPlayerPid()
                local sid = self.chatMainModel:GetCurrentPlayerSid()
                if pid then
                    local resp = req.sendPlayerMessage(pid, sid, str, nil, nil, true)
                    if api.success(resp) then
                        self.view:ResetInputText()
                        local data = resp.val
                        self.view:SetSendToEndState(self.currentChatType)
                        self.chatMainModel:InitWithProtocol(data, self.currentChatType)
                        self.view:RefreshPlayerScrollView(self.chatMainModel:GetCurrentNewPlayerMsgList(), self.currentChatType)
                    else
                        local data = resp.val
                        DialogManager.ShowToastByLang(data)
                    end
                end
            elseif self.currentChatType == CHAT_TYPE.GUILD then
                local resp = req.sendGuildMessage(str, nil, nil, true)
                if api.success(resp) then
                    self.view:ResetInputText()
                    local data = resp.val
                    self.view:SetSendToEndState(self.currentChatType)
                    self.chatMainModel:InitWithProtocol(data, self.currentChatType)
                    self:RefreshChatView()
                else
                    local data = resp.val
                    DialogManager.ShowToastByLang(data)
                end
            elseif self.currentChatType == CHAT_TYPE.GLOBAL then
                --聊天还没出参考界面，和接口
                local resp = req.sendGlobalMessage(str, nil, nil, true)
                if api.success(resp) then
                    self.view:ResetInputText()
                    local data = resp.val
                    self.view:SetSendToEndState(self.currentChatType)
                    self.chatMainModel:InitWithProtocol(data, self.currentChatType)
                    self:RefreshChatView()
                else
                    local data = resp.val
                    DialogManager.ShowToastByLang(data)
                end
            end
        end)
    end

    self.view.selectWorldFunc = function()
        if self.currentChatType ~= CHAT_TYPE.WORLD then
            self.currentChatType = CHAT_TYPE.WORLD
            self:InitReceiveMessage()
            self.chatMainModel:SetCurrentPlayerPid(nil)
            self.view:SetSelectBtnState(self.currentChatType)
        end
    end

    self.view.selectGuildFunc = function()
        if self.currentChatType ~= CHAT_TYPE.GUILD then
            self.currentChatType = CHAT_TYPE.GUILD
            self:InitReceiveMessage()
            self.chatMainModel:ResetHasNewMsgGuildList()
            self.chatMainModel:SetCurrentPlayerPid(nil)
            self.view:SetSelectBtnState(self.currentChatType)
        end
    end

    self.view.selectPlayerFunc = function()
        if self.currentChatType ~= CHAT_TYPE.PLAYER then
            self.currentChatType = CHAT_TYPE.PLAYER
            self:InitReceiveMessage()
            self.chatMainModel:RemoveNewMsgPlayerListItem(self.chatMainModel:GetCurrentPlayerPid())
            EventSystem.SendEvent("SidePlayerScroll_SelectedItem", self.chatMainModel:GetCurrentPlayerPid())            
            EventSystem.SendEvent("MainModel_PlayerHasNewMessage", self.chatMainModel:GetNewMsgPlayerList())            
            self.view:SetSelectBtnState(self.currentChatType)
        end
    end

    self.view.selectGlobalFunc = function()
        if self.currentChatType ~= CHAT_TYPE.GLOBAL then
            self.currentChatType = CHAT_TYPE.GLOBAL
            --请求接口袋盖
            self:InitReceiveMessage()
            self.chatMainModel:SetCurrentPlayerPid(nil)
            self.view:SetSelectBtnState(self.currentChatType)
        end
    end

    self.view.onBtnPacketClick = function()
        local list  = self.chatMainModel:GetPacketList()
        if #list > 0 then
            local index = list[#list].index
            self.view:ScrollToIndex(index)
        end
    end

	self.view.initMessage = function() self:InitReceiveMessage() end
	self.view.refreshMessage = function() self:RefreshReceiveMessage() end

    self.view:SetSelectBtnState(self.currentChatType)

    self:PrivateChat()
end

function ChatMainCtrl:Refresh()
    self:OnEnterScene()
    self.view:RecieveChatMessage()
end

function ChatMainCtrl:InitLimitText()
    local level = self.playerInfoModel:GetLevel()
    self.view:InitLimitText(self.chatMainModel, level, self.currentChatType)
end

function ChatMainCtrl:CheckSendMsg(message)
    local level = self.playerInfoModel:GetLevel()

    if string.len(message) == 0 then
        DialogManager.ShowToastByLang("chat_emptytips")
        return false
    end
    if self.currentChatType == CHAT_TYPE.WORLD then
        if level < self.chatMainModel:GetWorldLimitLevel() then
            DialogManager.ShowToastByLang("chat_lvtips")
            return false
        end
        if self.chatMainModel:GetWorldLimitTime() > 0 then
            DialogManager.ShowToast(lang.trans("chat_timetips", self.chatMainModel:GetWorldLimitTime()))
            return false
        end
        
    end

    return true
end

function ChatMainCtrl:OnEnterScene()
    EventSystem.AddEvent("SideChatScroll_ClickReceiced", self, self.EventClickReceived)
    EventSystem.AddEvent("ChatTipDialog_SideChat", self, self.EventAddSideChatItem)
    EventSystem.AddEvent("ChatScrollerView_CalculateCount", self, self.CalculateUnreadMsg)
    EventSystem.AddEvent("MainModel_PlayerHasNewMessage", self, self.EventPlayerHasNewMessage)
    EventSystem.AddEvent("SideChatScroll_RemoveItem", self, self.EventRemoveSideChatItem)
    EventSystem.AddEvent("ChatItem_ClickPacket", self, self.EventItemPacketClick)
    EventSystem.AddEvent("ScrollPos_SetNewPacketPanel", self, self.SetNewPacketPanel)
    EventSystem.AddEvent("MainModel_GuildHasNewMessage", self, self.EventGuildHasNewMessage)
end

function ChatMainCtrl:OnExitScene()
    EventSystem.RemoveEvent("SideChatScroll_ClickReceiced", self, self.EventClickReceived)
    EventSystem.RemoveEvent("ChatTipDialog_SideChat", self, self.EventAddSideChatItem)
    EventSystem.RemoveEvent("ChatScrollerView_CalculateCount", self, self.CalculateUnreadMsg)
    EventSystem.RemoveEvent("MainModel_PlayerHasNewMessage", self, self.EventPlayerHasNewMessage)
    EventSystem.RemoveEvent("SideChatScroll_RemoveItem", self, self.EventRemoveSideChatItem)
    EventSystem.RemoveEvent("ChatItem_ClickPacket", self, self.EventItemPacketClick)
    EventSystem.RemoveEvent("ScrollPos_SetNewPacketPanel", self, self.SetNewPacketPanel)
    EventSystem.RemoveEvent("MainModel_GuildHasNewMessage", self, self.EventGuildHasNewMessage)
end

function ChatMainCtrl:EventPlayerHasNewMessage(newlist)
    self.view:SetPlayerRedTip(#newlist > 0)
end

function ChatMainCtrl:EventGuildHasNewMessage(newList)
    self.view:SetGuildRedTip(#newList > 0)
end

function ChatMainCtrl:CalculateUnreadMsg(count)
    if tonumber(count) == -1 then
        self.chatMainModel:ResetUnreadMsgCount()
    else
        self.chatMainModel:AppendUnreadMsgCount(count)
    end
    self:SetUnreadMsgPanelState()
end

function ChatMainCtrl:SetUnreadMsgPanelState()
    local unReadCount = self.chatMainModel:GetUnReadMsgCount()
    if unReadCount <= 0 then
        self.view:SetNewMsgPanel(false)
    else
        self.view:SetNewMsgPanel(true)
        self.view:SetNewMsgText(lang.trans("chatNewMsg", unReadCount))
    end
end

function ChatMainCtrl:EventClickReceived(pid, sid)
    if pid ~= self.chatMainModel:GetCurrentPlayerPid() then
        self.view:InitPlayerScrollView(self.chatMainModel:GetPlayerMsgList(pid, sid), self.currentChatType)
    end
    self.chatMainModel:RemoveNewMsgPlayerListItem(pid)
end

function ChatMainCtrl:EventAddSideChatItem(tipModel)
    local respone = req.receiveMessage(self.chatMainModel:GetLastWorldSeq(), self.chatMainModel:GetLastGuildSeq(), self.chatMainModel:GetLastPlayerSeq(), self.chatMainModel:GetLastGlobalSeq(), nil, nil, true)
    if api.success(respone) then
        local data = respone.val
        self.chatMainModel:InitWithProtocol(data, self.currentChatType)
        self.currentChatType = CHAT_TYPE.PLAYER
        self.chatMainModel:AddPlayerInfoList(tipModel:GetSender())
        self:InitChatView()
        self.view:SetSelectBtnState(self.currentChatType)
        self.chatMainModel:RemoveNewMsgPlayerListItem(self.chatMainModel:GetCurrentPlayerPid())
        EventSystem.SendEvent("SidePlayerScroll_SelectedItem", self.chatMainModel:GetCurrentPlayerPid())
    end
end

function ChatMainCtrl:EventRemoveSideChatItem(pid, sid)
    self.chatMainModel:RemovePlayerInfoListItem(pid)
    self.chatMainModel:SetCurrentPlayerPid(nil)
    EventSystem.SendEvent("SidePlayerScroll_SelectedItem", self.chatMainModel:GetCurrentPlayerPid())
    self.view:InitPlayerChatView(self.chatMainModel:GetPlayerInfoList(), self.chatMainModel:GetCurrentPlayerMsgList(), self.currentChatType)
end

function ChatMainCtrl:InitReceiveMessage()
    local respone = req.receiveMessage(self.chatMainModel:GetLastWorldSeq(), self.chatMainModel:GetLastGuildSeq(), self.chatMainModel:GetLastPlayerSeq(), self.chatMainModel:GetLastGlobalSeq(), nil, nil, true)
    if api.success(respone) then
        local data = respone.val
        self.chatMainModel:InitWithProtocol(data, self.currentChatType)
        self:InitChatView()
    end
end

function ChatMainCtrl:RefreshReceiveMessage()
    local respone = req.receiveMessage(self.chatMainModel:GetLastWorldSeq(), self.chatMainModel:GetLastGuildSeq(), self.chatMainModel:GetLastPlayerSeq(), self.chatMainModel:GetLastGlobalSeq(), nil, nil, true)
    if api.success(respone) then
        local data = respone.val
        self.chatMainModel:InitWithProtocol(data, self.currentChatType)
        self:RefreshChatView()
    end
end

function ChatMainCtrl:InitChatView()
    if self.currentChatType == CHAT_TYPE.WORLD then
        self.view:InitWorldChatView(self.chatMainModel:GetWorldMsgList(), self.currentChatType)
    elseif self.currentChatType == CHAT_TYPE.PLAYER then
        self.view:InitPlayerChatView(self.chatMainModel:GetPlayerInfoList(), self.chatMainModel:GetFirstPlayerMsgList(), self.currentChatType)
    elseif self.currentChatType == CHAT_TYPE.GUILD then
        self.view:InitWorldChatView(self.chatMainModel:GetGuildMsgList(), self.currentChatType)
    elseif self.currentChatType == CHAT_TYPE.GLOBAL then
        self.view:InitGlobalChatView(self.chatMainModel:GetGlobalMsgList(), self.currentChatType)
    end
    self:InitLimitText()
    self:SetNewPacketPanel()
    self:SendPlayerHasNewMsgEvent()
end

function ChatMainCtrl:RefreshChatView()
    if self.currentChatType == CHAT_TYPE.WORLD then
        self.view:RefreshWorldView(self.chatMainModel:GetNewWorldMsgList(), self.currentChatType)
    elseif self.currentChatType == CHAT_TYPE.PLAYER then
        self.view:RefreshPlayerView(self.chatMainModel:GetNewPlayerInfoList(), self.chatMainModel:GetCurrentNewPlayerMsgList(), self.currentChatType)
    elseif self.currentChatType == CHAT_TYPE.GLOBAL then
        self.view:RefreshWorldView(self.chatMainModel:GetNewGlobalMsgList(), self.currentChatType)
    else
        self.view:RefreshWorldView(self.chatMainModel:GetNewGuildMsgList(), self.currentChatType)
    end
    self:SetNewPacketPanel()
    self:SendPlayerHasNewMsgEvent()
end

function ChatMainCtrl:SendPlayerHasNewMsgEvent()
    local playerList = self.chatMainModel:GetNewMsgPlayerList()  
    if #playerList > 0 then
        EventSystem.SendEvent("MainModel_PlayerHasNewMessage", playerList)
    end
end

function ChatMainCtrl:EventItemPacketClick(id, type)
    clr.coroutine(function()
        local respone = req.viewRedEnvelope(id, type)
        if api.success(respone) then
            local data = respone.val
            data._id = id
            res.PushDialog("ui.controllers.chat.ChatRedPacketCtrl", data, type)
            self.chatMainModel:RemovePacketListItem(id)
            self:SetNewPacketPanel()
        end
    end)
end

function ChatMainCtrl:SetNewPacketPanel()
    if self.currentChatType == CHAT_TYPE.GUILD then
        local visibleIndex = self.view:GetVisibleItemIndex()
        local list = self.chatMainModel:GetPacketList()
        if #list > 0 then
            if list[#list].index < visibleIndex + 2 then
                self.view:SetNewPacketPanel(true)
                self.view:SetNewPacketText("X  " .. #list)
            else
                self.view:SetNewPacketPanel(false)
            end
        else
            self.view:SetNewPacketPanel(false)
        end
    else
        self.view:SetNewPacketPanel(false)
    end
end

-- 玩家详情跳转私聊，避免使用事件传递不过来的情况
function ChatMainCtrl:PrivateChat()
    local data = cache.getChatSideData()
    if data ~= nil then
        self:EventAddSideChatItem(data)
        cache.setChatSideData(nil)
    end
end

return ChatMainCtrl

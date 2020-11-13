local UnityEngine = clr.UnityEngine
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local CHAT_TYPE = require("ui.controllers.chat.CHAT_TYPE")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ChatMainView = class(unity.base)

function ChatMainView:ctor()
    self.close = self.___ex.close
    self.scrollEx = self.___ex.scrollEx
    self.sideScrollEx = self.___ex.sideScrollEx
    self.sideScroll = self.___ex.sideScroll
    self.inputField = self.___ex.inputField
    self.sendBtn = self.___ex.sendBtn
    self.canvasGroup = self.___ex.canvasGroup
    self.selectGlobalBtn = self.___ex.selectGlobalBtn
    self.selectWorldBtn = self.___ex.selectWorldBtn
    self.selectGuildBtn = self.___ex.selectGuildBtn
    self.selectPlayerBtn = self.___ex.selectPlayerBtn
    self.WholeChatArea = self.___ex.WholeChatArea
    self.SideChatArea = self.___ex.SideChatArea
    self.SideImageBg = self.___ex.SideImageBg
    self.newMsgText = self.___ex.newMsgText
    self.newMsgPanel = self.___ex.newMsgPanel
    self.playerRedTip = self.___ex.playerRedTip
    self.guildRedTip = self.___ex.guildRedTip
    self.newPacketPanel = self.___ex.newPacketPanel
    self.newPacketNum = self.___ex.newPacketNum
    self.btnPacket = self.___ex.btnPacket
    self.limitText = self.___ex.limitText
    self.selectBtn = {}
    table.insert(self.selectBtn, self.selectWorldBtn)
    table.insert(self.selectBtn, self.selectGuildBtn)
    table.insert(self.selectBtn, self.selectPlayerBtn) 
    table.insert(self.selectBtn, self.selectGlobalBtn) 

	self.isReceive = true
end

function ChatMainView:start()
    cache.setIsChatViewOpen(true)
    DialogAnimation.Appear(self.transform, self.canvasGroup)
    self.close:regOnButtonClick(function()
        self:Close()
    end)
    
    self.sendBtn:regOnButtonClick(function()
        if type(self.sendFunction) == "function" then
            self.sendFunction()
        end
    end)

    self.selectGlobalBtn:regOnButtonClick(function()
        if type(self.selectGlobalFunc) == "function" then
            self.selectGlobalFunc()
        end
    end)

    self.selectWorldBtn:regOnButtonClick(function()
        if type(self.selectWorldFunc) == "function" then
            self.selectWorldFunc()
        end
    end)

    self.selectGuildBtn:regOnButtonClick(function()
        if type(self.selectGuildFunc) == "function" then
            self.selectGuildFunc()
        end
    end)

    self.selectPlayerBtn:regOnButtonClick(function()
        if type(self.selectPlayerFunc) == "function" then
            self.selectPlayerFunc()
        end
    end)

    self.btnPacket:regOnButtonClick(function()
        if type(self.onBtnPacketClick) == "function" then
            self.onBtnPacketClick()
        end
    end)

end

function ChatMainView:SetSelectBtnState(curState)
    for i = 1, #self.selectBtn do
        if i == curState then
            self.selectBtn[i].select:SetActive(true)
        else
            self.selectBtn[i].select:SetActive(false)
        end
    end
end

function ChatMainView:Close()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end)
end

function ChatMainView:InitWorldChatView(data, currentChatType)
    self.WholeChatArea:SetActive(true)
    self.SideChatArea:SetActive(false)
    self.SideImageBg:SetActive(false)
    self.scrollEx:InitView(data, currentChatType)
end

function ChatMainView:InitGlobalChatView(data, currentChatType)
    self.WholeChatArea:SetActive(true)
    self.SideChatArea:SetActive(false)
    self.SideImageBg:SetActive(false)
    self.scrollEx:InitView(data, currentChatType)
end

function ChatMainView:InitPlayerInfoView(playerinfo)
    self.sideScroll:InitView(playerinfo)    
end

function ChatMainView:InitPlayerScrollView(data, currentChatType)
    self.sideScrollEx:InitView(data, currentChatType)
end

function ChatMainView:RefreshPlayerScrollView(data, currentChatType)
    self.sideScrollEx:RefreshView(data, currentChatType)
end

function ChatMainView:InitPlayerChatView(playerinfo, data, currentChatType)
    self.WholeChatArea:SetActive(false)
    self.SideChatArea:SetActive(true)
    self.SideImageBg:SetActive(true)
    self:InitPlayerInfoView(playerinfo)
    self:InitPlayerScrollView(data, currentChatType)
end

function ChatMainView:RefreshWorldView(data, currentChatType)
    self.scrollEx:RefreshView(data, currentChatType)
end

function ChatMainView:RefreshPlayerInfoView(playerinfo)
    self.sideScroll:RefreshView(playerinfo)  
end

function ChatMainView:RefreshPlayerView(playerinfo, data, currentChatType)
    self:RefreshPlayerInfoView(playerinfo)
    self:RefreshPlayerScrollView(data, currentChatType)
end

function ChatMainView:SetSendToEndState(currentChatType)
    if currentChatType == CHAT_TYPE.WORLD then
        self.scrollEx:SetSendToEndState()
    elseif currentChatType == CHAT_TYPE.PLAYER then
        self.sideScrollEx:SetSendToEndState()
    end
end

function ChatMainView:ScrollToIndex(index)
    self.scrollEx:ScrollToIndex(index)
end

function ChatMainView:GetInputText()
    return self.inputField.text
end

function ChatMainView:ResetInputText()
    self.inputField.text = ""
end

function ChatMainView:SetNewMsgPanel(state)
    GameObjectHelper.FastSetActive(self.newMsgPanel, state)
end

function ChatMainView:SetNewMsgText(str)
    self.newMsgText.text = str
end

function ChatMainView:SetPlayerRedTip(state)
    GameObjectHelper.FastSetActive(self.playerRedTip, state)
end

function ChatMainView:SetGuildRedTip(state)
    GameObjectHelper.FastSetActive(self.guildRedTip, state)
end

function ChatMainView:SetNewPacketPanel(state)
    GameObjectHelper.FastSetActive(self.newPacketPanel, state)
end

function ChatMainView:SetNewPacketText(str)
    self.newPacketNum.text = str
end

function ChatMainView:InitLimitText(chatMainModel, level, currentChatType)
    if currentChatType ~= CHAT_TYPE.WORLD then
        self.limitText.text = ""
    else
        local freeCount = chatMainModel:GetWorldFreeCount()
        if level < chatMainModel:GetWorldLimitLevel() then
            self.limitText.text = lang.transstr("chat_LimitText1")
        else
            if freeCount > 0 then
                self.limitText.text = lang.transstr("chat_LimitText2", freeCount)
            else
                self.limitText.text = lang.transstr("chat_LimitText3")
            end
        end
    end
end

function ChatMainView:GetVisibleItemIndex()
    return self.scrollEx:GetVisibleItemIndex()
end

function ChatMainView:RecieveChatMessage()
    self:coroutine(function()
        coroutine.yield(UnityEngine.WaitForSeconds(0.2))
        self:InitReceiveMessage()
		while self.isReceive do
			coroutine.yield(UnityEngine.WaitForSeconds(3))
			self:RefreshReceiveMessage()
		end
    end)
end

function ChatMainView:InitReceiveMessage()
	if self.initMessage then 
		self.initMessage()
	end
end

function ChatMainView:RefreshReceiveMessage()
	if self.refreshMessage then 
		self.refreshMessage()
	end
end

function ChatMainView:onDestroy()
    cache.setIsChatViewOpen(nil)
	self.isReceive = false
end

return ChatMainView

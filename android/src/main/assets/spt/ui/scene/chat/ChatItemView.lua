local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local ChatTipDialogModel = require("ui.models.chat.ChatTipDialogModel")
local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Text = UI.Text
local Vector2 = UnityEngine.Vector2
local TextAnchor = UnityEngine.TextAnchor
local MEMBERTYPE = require("ui.controllers.guild.MEMBERTYPE")
local GuildRedEnvelope = require("data.GuildRedEnvelope")
local RedPacketModel = require("ui.models.RedPacketModel")
local CHAT_TYPE = require("ui.controllers.chat.CHAT_TYPE")

local ChatItemView = class(unity.base)

local exWidth = 30
local exHeight = 20

function ChatItemView:ctor()
    self.message = self.___ex.messageLabel
    self.messageRect = self.___ex.messageRect
    self.chatBg = self.___ex.chatBg
    self.teamLogo = self.___ex.teamlogo
    self.nameText = self.___ex.name
    self.level = self.___ex.level
    self.logoClickArea = self.___ex.logoClickArea
    self.authority = self.___ex.authority
    self.contentClick = self.___ex.contentClick
    self.packetImg = self.___ex.packetImg
    self.date = self.___ex.date
    self.diamondNum = self.___ex.diamondNum
    self.title = self.___ex.title

    self.chatItemModel = nil
end

function ChatItemView:start()
    if self.logoClickArea then
        self.logoClickArea:regOnButtonClick(function()
            if type(self.logoClickFunc) == "function" then
                self.logoClickFunc()
            end
        end)
    end
end

local function splitStr(str, p)
    local t = {}
    string.gsub(str, '[^'..p..']+', function(w) table.insert(t, w) end )
    return t
end 

function ChatItemView:InitView(chatItemModel, currentChatType)
    self.chatItemModel = chatItemModel
    if chatItemModel.currentChatType == CHAT_TYPE.GUILD or chatItemModel.currentChatType == CHAT_TYPE.GLOBAL then
        self.nameText.text = chatItemModel:GetName() .. chatItemModel:GetServer()
    else
        self.nameText.text = chatItemModel:GetName()
    end
    self.level.text = "Lv" .. tostring(chatItemModel:GetLevel())
    local logoTable = chatItemModel:GetTeamLogoInfo()
    TeamLogoCtrl.BuildTeamLogo(self.teamLogo, logoTable)
    if chatItemModel:GetAuthority() then
        if self.authority then
            self.authority.text = MEMBERTYPE[chatItemModel:GetAuthority()]
        end
    else
        if self.authority then
            self.authority.text = ""
        end
    end
    if chatItemModel:GetForm() then
        if chatItemModel:GetForm() == 1 then
            self.message.text = chatItemModel:GetMessage()
        elseif chatItemModel:GetForm() == 2 or chatItemModel:GetForm() == 3 then
            local messageTab = chatItemModel:GetMessage()
            self.contentClick:regOnButtonClick(function() 
                if type(self.packetcontentClick) == "function" then
                    self.packetcontentClick()
                end
            end)
            self.diamondNum.text = tostring(GuildRedEnvelope[tostring(messageTab.id)].diamond)
            local strTable = splitStr(messageTab.date, "-")
            self.date.text = strTable[2] .. "-" .. strTable[3]
            local path = "Assets/CapstonesRes/Game/UI/Scene/Chat/Image/RedPacket_" .. messageTab.id ..".png"
            local icon = res.LoadRes(path)
            self.packetImg.sprite = icon
            self.title.text = lang.trans("guild_rp")
        -- 公会道具红包
        elseif chatItemModel:GetForm() == 4 then
            local messageTab = chatItemModel:GetMessage()
            local redPacketModel = RedPacketModel.new(messageTab.id)
            self.diamondNum.text = redPacketModel:GetContentAmount()
            self.packetImg.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Chat/Image/RedPacket_1.png")
            local strTable = splitStr(messageTab.date, "-")
            self.date.text = strTable[2] .. "-" .. strTable[3]
            self.contentClick:regOnButtonClick(function()
                if type(self.packetcontentClick) == "function" then
                    self.packetcontentClick()
                end
            end)
            self.title.text = redPacketModel:GetName()
        end
    else
        self.message.text = chatItemModel:GetMessage()
    end

    self:coroutine(function()
        unity.waitForNextEndOfFrame()
        if chatItemModel:GetForm() then
            if chatItemModel:GetForm() == 1 then
                self.chatBg.sizeDelta = Vector2(self.messageRect.sizeDelta.x + exWidth, self.messageRect.sizeDelta.y + exHeight)
            else
                self.chatBg.sizeDelta = Vector2(235, 144)
            end
        else
            self.chatBg.sizeDelta = Vector2(self.messageRect.sizeDelta.x + exWidth, self.messageRect.sizeDelta.y + exHeight)
        end
    end)
end

return ChatItemView

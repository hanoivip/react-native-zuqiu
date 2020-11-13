local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Text = UI.Text
local Vector2 = UnityEngine.Vector2
local TextAnchor = UnityEngine.TextAnchor

local SidePlayerItemView = class(unity.base)

function SidePlayerItemView:ctor()
    self.teamLogo = self.___ex.teamlogo
    self.nameText = self.___ex.name
    self.content = self.___ex.content
    self.selectImg = self.___ex.selectImg
    self.redTip = self.___ex.redTip
    self.close = self.___ex.close
    self.sidePlayerItemModel = nil
    EventSystem.AddEvent("SidePlayerScroll_SelectedItem", self, self.EventSelectedReceived)
    EventSystem.AddEvent("MainModel_PlayerHasNewMessage", self, self.EventHasNewMessage)
end

function SidePlayerItemView:start()
    self.content:regOnButtonClick(function() 
        if type(self.clickReceive) == "function" then
            self.clickReceive()
        end
    end)

    self.close:regOnButtonClick(function()
        if type(self.clickClose) == "function" then
            self.clickClose()
        end
    end)
end

function SidePlayerItemView:InitView(sidePlayerItemModel)
    self.sidePlayerItemModel = sidePlayerItemModel
    self.nameText.text = sidePlayerItemModel:GetName()
    local logoTable = sidePlayerItemModel:GetTeamLogoInfo()
    TeamLogoCtrl.BuildTeamLogo(self.teamLogo, logoTable)
end

function SidePlayerItemView:EventSelectedReceived(pid)
    local state = self.sidePlayerItemModel:GetPid() == pid
    self:SetPlayerItemState(state)
    self:SetCloseBtnState(state)
end

function SidePlayerItemView:SetPlayerItemState(isSelected)
    self.selectImg:SetActive(isSelected)
end

function SidePlayerItemView:SetRedTip(state)
    self.redTip:SetActive(state)
end

function SidePlayerItemView:SetCloseBtnState(state)
    self.close.gameObject:SetActive(state)
end

function SidePlayerItemView:EventHasNewMessage(newlist)
    local flag = false
    for i = 1, #newlist do
        if self.sidePlayerItemModel:GetPid() == newlist[i] then
            flag = true
            break
        end
    end
    self.redTip:SetActive(flag)    
end

function SidePlayerItemView:onDestroy()
    EventSystem.RemoveEvent("SidePlayerScroll_SelectedItem", self, self.EventSelectedReceived)
    EventSystem.RemoveEvent("MainModel_PlayerHasNewMessage", self, self.EventHasNewMessage)
end

return SidePlayerItemView

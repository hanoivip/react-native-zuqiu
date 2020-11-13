local DynamicLoaded = require("ui.control.utils.DynamicLoaded")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local AssistCoachInfoBarView = class(DynamicLoaded, "AssistCoachInfoBarView")

local tostring = tostring
local tonumber = tonumber
local type = type

function AssistCoachInfoBarView:ctor()
    self.txtAce = self.___ex.txtAce
    self.btnAce = self.___ex.btnAce
    self.txtGold = self.___ex.txtGold
    self.txtDiamond = self.___ex.txtDiamond
    self.btnDiamond = self.___ex.btnDiamond
    self.btnBack = self.___ex.btnBack
    self.btnMoney = self.___ex.btnMoney
end

function AssistCoachInfoBarView:start()
    self:RegViewEvent()
    self:RegModelHandler()
end

function AssistCoachInfoBarView:InitView(playerInfoModel)
    self.playerInfoModel = playerInfoModel
end

function AssistCoachInfoBarView:RegViewEvent()
    self.btnAce:regOnButtonClick(function()
        self:OnBtnAceClick()
    end)
    self.btnDiamond:regOnButtonClick(function()
        self:OnBtnDiamondClick()
    end)
    self.btnMoney:regOnButtonClick(function()
        self:OnBtnMoneyClick()
    end)
    self.btnBack:regOnButtonClick(function()
        self:OnBtnBackClick()
    end)
end

function AssistCoachInfoBarView:OnBtnDiamondClick()
    if self.clickDiamond then
        self.clickDiamond()
    end
end

function AssistCoachInfoBarView:OnBtnMoneyClick()
    if self.clickMoney then
        self.clickMoney()
    end
end

function AssistCoachInfoBarView:OnBtnAceClick()
    if self.clickAce then
        self.clickAce()
    end
end

function AssistCoachInfoBarView:OnBtnBackClick()
    if self.clickBack then
        self.clickBack()
    end
end

function AssistCoachInfoBarView:RegModelHandler()
    EventSystem.AddEvent("PlayerInfo", self, self.EventPlayerInfo)
end

function AssistCoachInfoBarView:RemoveModelHandler()
    EventSystem.RemoveEvent("PlayerInfo", self, self.EventPlayerInfo)
end

function AssistCoachInfoBarView:EventPlayerInfo(playerInfoModel)
    local info = {
        ace = tonumber(playerInfoModel:GetAssistantCoachExp()),
        gold = tonumber(playerInfoModel:GetMoney()),
        diamond = tonumber(playerInfoModel:GetDiamond()),
    }
    self:UpdateInfo(info)
end

function AssistCoachInfoBarView:UpdateInfo(info)
    assert(type(info) == "table", "playerInfo is not a table !")

    if info.ace then
        self.txtAce.text = tostring(info.ace)
    end
    if info.gold then
        self.txtGold.text = string.formatNumWithUnit(info.gold)
    end
    if info.diamond then
        self.txtDiamond.text = tostring(info.diamond)
    end
end

function AssistCoachInfoBarView:onDestroy()
    self:RemoveModelHandler()
end

return AssistCoachInfoBarView


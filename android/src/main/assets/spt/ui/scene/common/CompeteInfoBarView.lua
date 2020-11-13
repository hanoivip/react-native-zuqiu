local DynamicLoaded = require("ui.control.utils.DynamicLoaded")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CompeteInfoBarView = class(DynamicLoaded)

local tostring = tostring
local tonumber = tonumber
local type = type

function CompeteInfoBarView:ctor()
    self.txtCompete = self.___ex.txtCompete
    self.btnCompete = self.___ex.btnCompete
    self.txtGold = self.___ex.txtGold
    self.txtDiamond = self.___ex.txtDiamond
    self.btnDiamond = self.___ex.btnDiamond
    self.btnBack = self.___ex.btnBack
    self.btnMoney = self.___ex.btnMoney
end

function CompeteInfoBarView:start()
    self:RegViewEvent()
    self:RegModelHandler()
end

function CompeteInfoBarView:InitView(playerInfoModel)
    self.playerInfoModel = playerInfoModel
end

function CompeteInfoBarView:RegViewEvent()
    self.btnCompete:regOnButtonClick(function()
        self:OnBtnCompeteClick()
    end)
    self.btnDiamond:regOnButtonClick(function()
        self:OnBtnDiamondClick()
    end)
    self.btnBack:regOnButtonClick(function()
        self:OnBtnBackClick()
    end)
    self.btnMoney:regOnButtonClick(function()
        self:OnBtnMoneyClick()
    end)
end

function CompeteInfoBarView:OnBtnDiamondClick()
    if self.clickDiamond then
        self.clickDiamond()
    end
end

function CompeteInfoBarView:OnBtnMoneyClick()
    if self.clickMoney then
        self.clickMoney()
    end
end

function CompeteInfoBarView:OnBtnCompeteClick()
    if self.clickCompete then
        self.clickCompete()
    end
end

function CompeteInfoBarView:OnBtnBackClick()
    if self.clickBack then
        self.clickBack()
    end
end

function CompeteInfoBarView:RegModelHandler()
    EventSystem.AddEvent("PlayerInfo", self, self.EventPlayerInfo)
end

function CompeteInfoBarView:RemoveModelHandler()
    EventSystem.RemoveEvent("PlayerInfo", self, self.EventPlayerInfo)
end

function CompeteInfoBarView:EventPlayerInfo(playerInfoModel)
    local info = {
        wtc = tonumber(playerInfoModel:GetCompeteCurrency()),
        gold = tonumber(playerInfoModel:GetMoney()),
        diamond = tonumber(playerInfoModel:GetDiamond()),
    }
    self:UpdateInfo(info)
end

function CompeteInfoBarView:UpdateInfo(info)
    assert(type(info) == "table", "playerInfo is not a table !")
	
    if info.wtc then
        local currentCompete = tostring(info.wtc)
        self.txtCompete.text = currentCompete
    end
    if info.gold then
        self.txtGold.text = string.formatNumWithUnit(info.gold)
    end
    if info.diamond then
        self.txtDiamond.text = tostring(info.diamond)
    end
end

function CompeteInfoBarView:onDestroy()
    self:RemoveModelHandler()
end

return CompeteInfoBarView


local DynamicLoaded = require("ui.control.utils.DynamicLoaded")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local TransportInfoBarView = class(DynamicLoaded)

local tostring = tostring
local tonumber = tonumber
local type = type

function TransportInfoBarView:ctor()
    self.btnBack = self.___ex.btnBack
    self.btnDiamond = self.___ex.btnDiamond
    self.txtDiamond = self.___ex.txtDiamond
    self.txtGold = self.___ex.txtGold
    self.btnMoney = self.___ex.btnMoney
end

function TransportInfoBarView:start()
    self:RegViewEvent()
    self:RegModelHandler()
end

function TransportInfoBarView:InitView(playerInfoModel)
    self.playerInfoModel = playerInfoModel
    self.txtDiamond.text = tostring(self.playerInfoModel:GetDiamond())
    self.txtGold.text = string.formatNumWithUnit(self.playerInfoModel:GetMoney())
end

function TransportInfoBarView:RegViewEvent()
    self.btnBack:regOnButtonClick(function()
        self:OnBtnBackClick()
    end)
    self.btnDiamond:regOnButtonClick(function()
        self:OnBtnDiamondClick()
    end)
    self.btnMoney:regOnButtonClick(function()
        self:OnBtnMoneyClick()
    end)
end

function TransportInfoBarView:OnBtnDiamondClick()
    if self.clickDiamond then
        self.clickDiamond()
    end
end

function TransportInfoBarView:OnBtnBackClick()
    if self.clickBack then
        self.clickBack()
    end
end

function TransportInfoBarView:OnBtnMoneyClick()
    if self.clickMoney then
        self.clickMoney()
    end
end

function TransportInfoBarView:RegModelHandler()
    EventSystem.AddEvent("PlayerInfo", self, self.EventPlayerInfo)
end

function TransportInfoBarView:RemoveModelHandler()
    EventSystem.RemoveEvent("PlayerInfo", self, self.EventPlayerInfo)
end

function TransportInfoBarView:EventPlayerInfo(playerInfoModel)
    local info = {
        diamond = tonumber(playerInfoModel:GetDiamond()),
        gold = tonumber(playerInfoModel:GetMoney()),
    }
    self:UpdateInfo(info)
end
function TransportInfoBarView:UpdateInfo(info)
    assert(type(info) == "table", "playerInfo is not a table !")
    if info.diamond then
        self.txtDiamond.text = tostring(info.diamond)
    end
    if info.gold then
        self.txtGold.text = string.formatNumWithUnit(info.gold)
    end
end

function TransportInfoBarView:onDestroy()
    self:RemoveModelHandler()
end

return TransportInfoBarView


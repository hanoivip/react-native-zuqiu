local DynamicLoaded = require("ui.control.utils.DynamicLoaded")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local HeroHallInfoBarView = class(DynamicLoaded)

local tostring = tostring
local tonumber = tonumber
local type = type

function HeroHallInfoBarView:ctor()
    self.btnBack = self.___ex.btnBack
    self.txtMoney = self.___ex.txtMoney
    self.btnMoney = self.___ex.btnMoney
    self.txtDiamond = self.___ex.txtDiamond
    self.btnDiamond = self.___ex.btnDiamond
    self.txtSmd = self.___ex.txtSmd
    self.btnSmd = self.___ex.btnSmd
    self.txtSmb = self.___ex.txtSmb
    self.btnSmb = self.___ex.btnSmb
end

function HeroHallInfoBarView:start()
    self:RegViewEvent()
    self:RegModelHandler()
end

function HeroHallInfoBarView:InitView(playerInfoModel)
    self.playerInfoModel = playerInfoModel
end

function HeroHallInfoBarView:RegViewEvent()
    self.btnBack:regOnButtonClick(function()
        self:OnBtnBackClick()
    end)
    self.btnMoney:regOnButtonClick(function()
        self:OnBtnMoneyClick()
    end)
    self.btnDiamond:regOnButtonClick(function()
        self:OnBtnDiamondClick()
    end)
    self.btnSmd:regOnButtonClick(function()
        self:OnBtnSmdClick()
    end)
    self.btnSmb:regOnButtonClick(function()
        self:OnBtnSmbClick()
    end)
end

function HeroHallInfoBarView:OnBtnBackClick()
    if self.clickBack then
        self.clickBack()
    end
end

function HeroHallInfoBarView:OnBtnDiamondClick()
    if self.clickDiamond then
        self.clickDiamond()
    end
end

function HeroHallInfoBarView:OnBtnMoneyClick()
    if self.clickMoney then
        self.clickMoney()
    end
end

function HeroHallInfoBarView:OnBtnSmdClick()
    if self.clickSmd then
        self.clickSmd()
    end
end

function HeroHallInfoBarView:OnBtnSmbClick()
    if self.clickSmb then
        self.clickSmb()
    end
end

function HeroHallInfoBarView:RegModelHandler()
    EventSystem.AddEvent("PlayerInfo", self, self.EventPlayerInfo)
end

function HeroHallInfoBarView:RemoveModelHandler()
    EventSystem.RemoveEvent("PlayerInfo", self, self.EventPlayerInfo)
end

function HeroHallInfoBarView:EventPlayerInfo(playerInfoModel)
    local info = {
        smd = tonumber(playerInfoModel:GetHeroHallSmdCurrency()),
        smb = tonumber(playerInfoModel:GetHeroHallSmbCurrency()),
        gold = tonumber(playerInfoModel:GetMoney()),
        diamond = tonumber(playerInfoModel:GetDiamond()),
    }
    self:UpdateInfo(info)
end

function HeroHallInfoBarView:UpdateInfo(info)
    assert(type(info) == "table", "playerInfo is not a table !")

    if info.gold then
        self.txtMoney.text = string.formatNumWithUnit(info.gold)
    end
    if info.diamond then
        self.txtDiamond.text = tostring(info.diamond)
    end
    if info.smd then
        self.txtSmd.text = string.formatNumWithUnit(info.smd)
    end
    if info.smb then
        self.txtSmb.text = string.formatNumWithUnit(info.smb)
    end
end

function HeroHallInfoBarView:onDestroy()
    self:RemoveModelHandler()
end

return HeroHallInfoBarView


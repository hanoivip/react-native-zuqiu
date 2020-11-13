local GreenswardEventActionEffectHelper = require("ui.models.greensward.event.GreenswardEventActionEffectHelper")
local DynamicLoaded = require("ui.control.utils.DynamicLoaded")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local GreenswardInfoBarView = class(DynamicLoaded)

local tostring = tostring
local tonumber = tonumber
local type = type

function GreenswardInfoBarView:ctor()
    self.txtMorale = self.___ex.txtMorale
    self.btnMorale = self.___ex.btnMorale
    self.txtDiamond = self.___ex.txtDiamond
    self.btnDiamond = self.___ex.btnDiamond
    self.btnBack = self.___ex.btnBack
	self.txtPower = self.___ex.txtPower
end

function GreenswardInfoBarView:start()
    self:RegViewEvent()
    self:RegModelHandler()
end

function GreenswardInfoBarView:InitView(playerInfoModel)
    self.playerInfoModel = playerInfoModel
end

function GreenswardInfoBarView:RegViewEvent()
    self.btnDiamond:regOnButtonClick(function()
        self:OnBtnDiamondClick()
    end)
    self.btnBack:regOnButtonClick(function()
        self:OnBtnBackClick()
    end)
    self.btnMorale:regOnButtonClick(function()
        self:OnBtnMoraleClick()
    end)
end

function GreenswardInfoBarView:OnBtnDiamondClick()
    if self.clickDiamond then
        self.clickDiamond()
    end
end

function GreenswardInfoBarView:OnBtnMoraleClick()
    if self.clickMorale then
        self.clickMorale()
    end
end

function GreenswardInfoBarView:OnBtnPowerClick()
    if self.clickPower then
        self.clickPower()
    end
end

function GreenswardInfoBarView:OnBtnBackClick()
    if self.clickBack then
        self.clickBack()
    end
end

function GreenswardInfoBarView:RegModelHandler()
    EventSystem.AddEvent("PlayerInfo", self, self.EventPlayerInfo)
	EventSystem.AddEvent("GreenswardInfoUpdate", self, self.EventGreenswardInfo)
end

function GreenswardInfoBarView:RemoveModelHandler()
    EventSystem.RemoveEvent("PlayerInfo", self, self.EventPlayerInfo)
	EventSystem.RemoveEvent("GreenswardInfoUpdate", self, self.EventGreenswardInfo)
end

function GreenswardInfoBarView:EventPlayerInfo(playerInfoModel)
    local info = {
        diamond = tonumber(playerInfoModel:GetDiamond()),
    }
    self:UpdateInfo(info)
end

local ShowTime = 0.2
local RepeatTime = 6 -- 2次一个循环
function GreenswardInfoBarView:EventGreenswardInfo(greenswardBuildModel)
	local powerNum = greenswardBuildModel:GetPowerNum()
	local moraleNum = greenswardBuildModel:GetMoraleNum()
    local preMorale = tonumber(self.txtMorale.text)
    local prePower = tonumber(self.txtPower.text)
    if moraleNum then
        self.txtMorale.text = tostring(moraleNum)
    end
    if powerNum then
        self.txtPower.text = tostring(powerNum)
    end

    self.myMoraleSequence = GreenswardEventActionEffectHelper.BlingExtensions(moraleNum, preMorale, self.myMoraleSequence, self.txtMorale)
    self.myPowerSequence = GreenswardEventActionEffectHelper.BlingExtensions(powerNum, prePower, self.myPowerSequence, self.txtPower)
end

function GreenswardInfoBarView:UpdateInfo(info)
    assert(type(info) == "table", "playerInfo is not a table !")
	
    if info.diamond then
        self.txtDiamond.text = tostring(info.diamond)
    end
end

function GreenswardInfoBarView:onDestroy()
    self:RemoveModelHandler()
    if self.myMoraleSequence then
        GreenswardEventActionEffectHelper.DestroyExtensions(self.myMoraleSequence)
    end
    if self.myPowerSequence then
        GreenswardEventActionEffectHelper.DestroyExtensions(self.myPowerSequence)
    end
end

return GreenswardInfoBarView


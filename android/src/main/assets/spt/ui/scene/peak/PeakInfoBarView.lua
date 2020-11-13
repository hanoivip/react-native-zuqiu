local DynamicLoaded = require("ui.control.utils.DynamicLoaded")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PeakInfoBarView = class(DynamicLoaded)

local tostring = tostring
local tonumber = tonumber
local type = type

function PeakInfoBarView:ctor()
    self.btnBack = self.___ex.btnBack
    self.btnDiamond = self.___ex.btnDiamond
    self.btnPeakDiamond = self.___ex.btnPeakDiamond
    self.txtPeakDiamond = self.___ex.txtPeakDiamond
    self.txtDiamond = self.___ex.txtDiamond
    self.anim = self.___ex.anim
end

function PeakInfoBarView:start()
    self:RegViewEvent()
    self:RegModelHandler()
end

function PeakInfoBarView:InitView(playerInfoModel)
    self.playerInfoModel = playerInfoModel
    self.txtPeakDiamond.text = tostring(self.playerInfoModel:GetPeakDiamond())
    self.txtDiamond.text = tostring(self.playerInfoModel:GetDiamond())
end

function PeakInfoBarView:RegViewEvent()
    self.btnBack:regOnButtonClick(function()
        self:OnBtnBackClick()
    end)
    self.btnDiamond:regOnButtonClick(function()
        self:OnBtnDiamondClick()
    end)
end

function PeakInfoBarView:OnBtnDiamondClick()
    if self.clickDiamond then
        self.clickDiamond()
    end
end

function PeakInfoBarView:OnBtnBackClick()
    if self.clickBack then
        self.clickBack()
    end
end

function PeakInfoBarView:RegModelHandler()
    EventSystem.AddEvent("PlayerInfo", self, self.EventPlayerInfo)
    EventSystem.AddEvent("Peak_Reveive_Diamond", self, self.RefreshAnimation)
end

function PeakInfoBarView:RemoveModelHandler()
    EventSystem.RemoveEvent("PlayerInfo", self, self.EventPlayerInfo)
    EventSystem.RemoveEvent("Peak_Reveive_Diamond", self, self.RefreshAnimation)
end

function PeakInfoBarView:RefreshAnimation()
    self.anim.gameObject:SetActive(false)
    self.anim.gameObject:SetActive(true)
end

function PeakInfoBarView:EventPlayerInfo(playerInfoModel)
    local info = {
        diamond = tonumber(playerInfoModel:GetDiamond()),
        pp = playerInfoModel:GetPeakDiamond()
    }
    self:UpdateInfo(info)
end
function PeakInfoBarView:UpdateInfo(info)
    assert(type(info) == "table", "playerInfo is not a table !")
    if info.diamond then
        self.txtDiamond.text = tostring(info.diamond)
    end
    if info.pp then
        self.txtPeakDiamond.text = tostring(info.pp)
    end
end

function PeakInfoBarView:onDestroy()
    self:RemoveModelHandler()
end

return PeakInfoBarView


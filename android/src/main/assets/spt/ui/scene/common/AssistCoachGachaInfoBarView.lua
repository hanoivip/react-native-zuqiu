local DynamicLoaded = require("ui.control.utils.DynamicLoaded")

local AssistCoachGachaInfoBarView = class(DynamicLoaded, "AssistCoachGachaInfoBarView")

local tostring = tostring
local tonumber = tonumber
local type = type

function AssistCoachGachaInfoBarView:ctor()
    self.txtDiamond = self.___ex.txtDiamond
    self.btnDiamond = self.___ex.btnDiamond
    self.btnBack = self.___ex.btnBack
    self.btnAce = self.___ex.btnAce
    self.txtAce = self.___ex.txtAce
    self.ticketOneGo = self.___ex.ticketOneGo
    self.ticketTenGo = self.___ex.ticketTenGo
    self.ticketOneTxt = self.___ex.ticketOneTxt
    self.ticketTenTxt = self.___ex.ticketTenTxt
end

function AssistCoachGachaInfoBarView:start()
    self:RegViewEvent()
    self:RegModelHandler()
end

function AssistCoachGachaInfoBarView:InitView(playerInfoModel, assistCoachGachaModel)
    self.playerInfoModel = playerInfoModel
    self.assistCoachGachaModel = assistCoachGachaModel
    self:EventPlayerInfo(playerInfoModel)
    self:UpdateItem()
end

function AssistCoachGachaInfoBarView:RegViewEvent()
    self.btnAce:regOnButtonClick(function()
        self:OnBtnAceClick()
    end)
    self.btnDiamond:regOnButtonClick(function()
        self:OnBtnDiamondClick()
    end)
    self.btnBack:regOnButtonClick(function()
        self:OnBtnBackClick()
    end)
end

function AssistCoachGachaInfoBarView:OnBtnDiamondClick()
    if self.clickDiamond then
        self.clickDiamond()
    end
end

function AssistCoachGachaInfoBarView:OnBtnAceClick()
    if self.clickAce then
        self.clickAce()
    end
end

function AssistCoachGachaInfoBarView:OnBtnBackClick()
    if self.clickBack then
        self.clickBack()
    end
end

function AssistCoachGachaInfoBarView:RegModelHandler()
    EventSystem.AddEvent("PlayerInfo", self, self.EventPlayerInfo)
    EventSystem.AddEvent("ItemsMapModel_ResetItemNum", self, self.UpdateItem)
end

function AssistCoachGachaInfoBarView:RemoveModelHandler()
    EventSystem.RemoveEvent("PlayerInfo", self, self.EventPlayerInfo)
    EventSystem.RemoveEvent("ItemsMapModel_ResetItemNum", self, self.UpdateItem)

end

function AssistCoachGachaInfoBarView:EventPlayerInfo(playerInfoModel)
    local info = {
        ace = tonumber(playerInfoModel:GetAssistantCoachExp()),
        diamond = tonumber(playerInfoModel:GetDiamond()),
    }
    self:UpdateInfo(info)
end

function AssistCoachGachaInfoBarView:UpdateInfo(info)
    assert(type(info) == "table", "playerInfo is not a table !")
    if info.ace then
        self.txtAce.text = tostring(info.ace)
    end
    if info.diamond then
        self.txtDiamond.text = tostring(info.diamond)
    end
end

function AssistCoachGachaInfoBarView:UpdateItem()
    local oneCount = self.assistCoachGachaModel:GetCachaOneItemCount()
    local tenCount = self.assistCoachGachaModel:GetCachaTenItemCount()
    self.ticketOneTxt.text = tostring(oneCount)
    self.ticketTenTxt.text = tostring(tenCount)
end

function AssistCoachGachaInfoBarView:onDestroy()
    self:RemoveModelHandler()
end

return AssistCoachGachaInfoBarView


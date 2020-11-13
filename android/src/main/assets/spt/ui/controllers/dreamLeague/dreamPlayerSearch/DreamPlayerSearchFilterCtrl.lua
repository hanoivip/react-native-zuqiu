local EventSystem = require ("EventSystem")
local DialogManager = require("ui.control.manager.DialogManager")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local DreamPlayerSearchFilterCtrl = class(BaseCtrl)

DreamPlayerSearchFilterCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamPlaySearch/DreamPlayerSearchFilterBoard.prefab"

function DreamPlayerSearchFilterCtrl:Refresh(dreamPlayerSearchModel)
    self.dreamPlayerSearchModel = dreamPlayerSearchModel
    self.dreamLeagueListModel = dreamPlayerSearchModel:GetDreamLeagueListModel()
    self.view:InitView(dreamPlayerSearchModel)
    self.view.clickConfirm = function(selectPos, selectQuality, selectLock)  self:ClickConfirm(selectPos, selectQuality, selectLock) end
    self.view.clickReset = function() self:OnBtnReset() end
end

function DreamPlayerSearchFilterCtrl:ClickConfirm(selectPos, selectQuality, selectLock)
    local selectModels = self.dreamPlayerSearchModel:GetFilterDcids(selectPos, selectQuality, selectLock)
    EventSystem.SendEvent("DreamPlayerSearchFilterCtrl_SetScrollDataFilter", selectModels)
    EventSystem.SendEvent("DreamPlayerSearchFilterCtrl_Refresh")
end

function DreamPlayerSearchFilterCtrl:OnBtnReset()
    self.view:OnReset()
end

function DreamPlayerSearchFilterCtrl:OnEnterScene()
    if self.view.OnEnterScene then
        self.view:OnEnterScene()
    end
end

function DreamPlayerSearchFilterCtrl:OnExitScene()
    if self.view.OnExitScene then
        self.view:OnExitScene()
    end
end

return DreamPlayerSearchFilterCtrl

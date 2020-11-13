local BaseCtrl = require("ui.controllers.BaseCtrl")
local CardBuilder = require("ui.common.card.CardBuilder")
local FormationCacheDataModel = require("ui.models.formation.FormationCacheDataModel")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local CardPowerCtrl = require("ui.controllers.cardDetail.CardPowerCtrl")

local PeakFormationPageCtrl = class(BaseCtrl)
PeakFormationPageCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Peak/PeakFormationPage.prefab"

function PeakFormationPageCtrl:Init(peakPlayerTeamsModel, formationCacheDataModel, tid)
    self.peakPlayerTeamsModel = peakPlayerTeamsModel
    self.formationCacheDataModel = formationCacheDataModel
    self.tid = self.tid
    if not self.formationCacheDataModel then
        self.formationCacheDataModel = FormationCacheDataModel.new(self.peakPlayerTeamsModel)
    end
    
    self:BindEvent()
end

function PeakFormationPageCtrl:Refresh(peakPlayerTeamsModel, formationCacheDataModel)
    PeakFormationPageCtrl.super.Refresh(self)
    self.peakPlayerTeamsModel = peakPlayerTeamsModel
    self.formationCacheDataModel = formationCacheDataModel or FormationCacheDataModel.new(self.peakPlayerTeamsModel)
    local isPush = nil
    local loadType = self:GetLoadType()
    if loadType == res.LoadType.Pop then
        isPush = false
    else
        isPush = true
    end
    self.view:InitView(self.peakPlayerTeamsModel, self.formationCacheDataModel, self.tid)
    self.view:RefreshPage(isPush)
end

function PeakFormationPageCtrl:OnEnterScene()
    self.view:RegisterEvent()
end

function PeakFormationPageCtrl:OnExitScene()
    self.view:UnRegisterEvent()
end

function PeakFormationPageCtrl:BindEvent()
    self.view.onCardClick = function (cardList, index, tid)
        self:OnCardClick(cardList, index, tid)
    end
    self.view:RegOnDynamicLoad(function (child)
        self.infoBarCtrl = InfoBarCtrl.new(child, self)
        self.infoBarCtrl:RegOnBtnBack(function()
            self.view:OnBack()
        end)
    end)
    self.view.onShowPower = function (powerValue)
        self:OnShowPower(powerValue)
    end
end

function PeakFormationPageCtrl:OnCardClick(cardList, index, tid)
    assert(tid)
    local currentModel = CardBuilder.GetFormationCardModel(cardList[index], self.formationCacheDataModel)
    res.PushScene("ui.controllers.cardDetail.CardDetailMainCtrl", cardList, index, currentModel)
end

function PeakFormationPageCtrl:OnShowPower(powerValue)
    if not self.powerCtrl then
        self.powerCtrl = CardPowerCtrl.new(self.view.powerNumArea, 4, 8)
    end
    self.powerCtrl:InitPower(powerValue)
end

function PeakFormationPageCtrl:GetStatusData()
    return self.peakPlayerTeamsModel, self.formationCacheDataModel
end

return PeakFormationPageCtrl
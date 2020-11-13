local BaseCtrl = require("ui.controllers.BaseCtrl")
local CardBuilder = require("ui.common.card.CardBuilder")
local FormationCacheDataModel = require("ui.models.formation.FormationCacheDataModel")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local CardPowerCtrl = require("ui.controllers.cardDetail.CardPowerCtrl")

local ArenaFormationPageCtrl = class(BaseCtrl)
ArenaFormationPageCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Arena/Prefab/ArenaFormationPage.prefab"

function ArenaFormationPageCtrl:Init(arenaPlayerTeamsModel, formationCacheDataModel)
    self.arenaPlayerTeamsModel = arenaPlayerTeamsModel
    self.formationCacheDataModel = formationCacheDataModel

    if self.formationCacheDataModel == nil then
        self.formationCacheDataModel = FormationCacheDataModel.new(self.arenaPlayerTeamsModel)
    end
    
    self:BindEvent()
end

function ArenaFormationPageCtrl:Refresh(arenaPlayerTeamsModel, formationCacheDataModel)
    ArenaFormationPageCtrl.super.Refresh(self)
    self.arenaPlayerTeamsModel = arenaPlayerTeamsModel
    self.formationCacheDataModel = formationCacheDataModel or FormationCacheDataModel.new(self.arenaPlayerTeamsModel)
    local isPush = nil
    local loadType = self:GetLoadType()
    if loadType == res.LoadType.Pop then
        isPush = false
    else
        isPush = true
    end
    self.view:InitView(self.arenaPlayerTeamsModel, self.formationCacheDataModel)
    self.view:RefreshPage(isPush)
end

function ArenaFormationPageCtrl:OnEnterScene()
    self.view:RegisterEvent()
end

function ArenaFormationPageCtrl:OnExitScene()
    self.view:UnRegisterEvent()
end

function ArenaFormationPageCtrl:BindEvent()
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

function ArenaFormationPageCtrl:OnCardClick(cardList, index, tid)
    assert(tid)
    local currentModel = CardBuilder.GetFormationCardModel(cardList[index], self.formationCacheDataModel)
    res.PushScene("ui.controllers.cardDetail.CardDetailMainCtrl", cardList, index, currentModel)
end

function ArenaFormationPageCtrl:OnShowPower(powerValue)
    if not self.powerCtrl then
        self.powerCtrl = CardPowerCtrl.new(self.view.powerNumArea, 4, 8)
    end
    self.powerCtrl:InitPower(powerValue)
end

function ArenaFormationPageCtrl:GetStatusData()
    return self.arenaPlayerTeamsModel, self.formationCacheDataModel
end

return ArenaFormationPageCtrl
local BaseCtrl = require("ui.controllers.BaseCtrl")
local CardBuilder = require("ui.common.card.CardBuilder")
local CompeteFormationCacheDataModel = require("ui.models.compete.main.CompeteFormationCacheDataModel")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local CardPowerCtrl = require("ui.controllers.cardDetail.CardPowerCtrl")

local CompeteFormationTeamCtrl = class(BaseCtrl)
CompeteFormationTeamCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Compete/Main/Prefab/CompeteFormationPage.prefab"

function CompeteFormationTeamCtrl:Init(competePlayerTeamsModel, competeFormationCacheDataModel)
    self.competePlayerTeamsModel = competePlayerTeamsModel
    self.competeFormationCacheDataModel = competeFormationCacheDataModel
    if self.competeFormationCacheDataModel == nil then
        self.competeFormationCacheDataModel = CompeteFormationCacheDataModel.new(self.competePlayerTeamsModel)
    end
    
    self:BindEvent()
end

function CompeteFormationTeamCtrl:Refresh(competePlayerTeamsModel, competeFormationCacheDataModel)
    CompeteFormationTeamCtrl.super.Refresh(self)
    self.competePlayerTeamsModel = competePlayerTeamsModel
    self.competeFormationCacheDataModel = competeFormationCacheDataModel or CompeteFormationCacheDataModel.new(self.competePlayerTeamsModel)
    local isPush = nil
    local loadType = self:GetLoadType()
    if loadType == res.LoadType.Pop then
        isPush = false
    else
        isPush = true
    end
    self.view:InitView(self.competePlayerTeamsModel, self.competeFormationCacheDataModel)
    self.view:RefreshPage(isPush)
    self.view:HideAutoBtnAndMoveClearBtn()
end

function CompeteFormationTeamCtrl:OnEnterScene()
    self.view:RegisterEvent()
end

function CompeteFormationTeamCtrl:OnExitScene()
    self.view:UnRegisterEvent()
end

function CompeteFormationTeamCtrl:BindEvent()
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

function CompeteFormationTeamCtrl:OnCardClick(cardList, index, tid)
    assert(tid)
    local currentModel = CardBuilder.GetFormationCardModel(cardList[index], self.competeFormationCacheDataModel)
    res.PushScene("ui.controllers.cardDetail.CardDetailMainCtrl", cardList, index, currentModel)
end

function CompeteFormationTeamCtrl:OnShowPower(powerValue)
    if not self.powerCtrl then
        self.powerCtrl = CardPowerCtrl.new(self.view.powerNumArea, 4, 8)
    end
    self.powerCtrl:InitPower(powerValue)
end

function CompeteFormationTeamCtrl:GetStatusData()
    return self.competePlayerTeamsModel, self.competeFormationCacheDataModel
end

return CompeteFormationTeamCtrl
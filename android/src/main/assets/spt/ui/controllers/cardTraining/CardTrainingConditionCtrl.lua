local GameObjectHelper = require("ui.common.GameObjectHelper")
local LegendRoadModel = require("ui.models.legendRoad.LegendRoadModel")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")

local CardTrainingConditionCtrl = class()

function CardTrainingConditionCtrl:ctor(cardTrainingMainModel, parent)
    self:Init(cardTrainingMainModel, parent)
end

function CardTrainingConditionCtrl:Init(cardTrainingMainModel, parent)
    self.cardTrainingMainModel = cardTrainingMainModel
    self.playerCardsMapModel = PlayerCardsMapModel.new()
    local pageObject, pageSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/CardTraining/Prefabs/ConditionContent.prefab")
    pageObject.transform:SetParent(parent, false)
    self.view = pageSpt
    self.view.confirmBtnClick = function () self:OnConfirmBtnClick() end
    self.view:InitView(cardTrainingMainModel)
end

function CardTrainingConditionCtrl:ShowGameObject()
    GameObjectHelper.FastSetActive(self.view.gameObject, true)
    self.view:InitView()
end

function CardTrainingConditionCtrl:HideGameObject()
    GameObjectHelper.FastSetActive(self.view.gameObject, false)
end

function CardTrainingConditionCtrl:OnConfirmBtnClick()
    clr.coroutine(function ()
        local pcid = self.cardTrainingMainModel:GetPcid()
        local trainId = self.cardTrainingMainModel:GetCurrLevelSelected()
        local response = req.cardTrainingOpen(pcid, trainId)
        if api.success(response) then
            local data = response.val
            self.playerCardsMapModel:ResetCardData(pcid, data.card)
            if data.supporterCard and data.supporterCard.pcid then
                PlayerCardsMapModel.new():ResetCardData(data.supporterCard.pcid, data.supporterCard)
            end
            if data.supporterData then
                local legendRoadModel = LegendRoadModel.new(self.cardTrainingMainModel:GetCardModel())
                legendRoadModel:RefreshLegendMapModel(data.supporterData)
            end
            EventSystem.SendEvent("CardTraining_RefreshMainView")
        end
    end)
end

return CardTrainingConditionCtrl

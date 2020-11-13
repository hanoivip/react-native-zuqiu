local DialogManager = require("ui.control.manager.DialogManager")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local TrainIntellectCtrl = class(BaseCtrl)
TrainIntellectCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/CardDetail/Prefabs/TrainIntellect.prefab"
TrainIntellectCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function TrainIntellectCtrl:Init(cardDetailModel, itemsMapModel)
    self.view.clickTrain = function(selectAttrMap, costVitaminNum) self:OnClickTrain(selectAttrMap, costVitaminNum) end

end

function TrainIntellectCtrl:Refresh(cardDetailModel, itemsMapModel)
    TrainIntellectCtrl.super.Refresh(self)
    self.cardDetailModel = cardDetailModel
    self.itemsMapModel = itemsMapModel
    self.view:InitView(cardDetailModel, itemsMapModel)
end

function TrainIntellectCtrl:OnClickTrain(selectAttrMap, costVitaminNum)
    local selectAttr = {}
    for abilityIndex, v in pairs(selectAttrMap) do
        if v then 
            table.insert(selectAttr, abilityIndex)
        end
    end
    local trainItemCount = self.itemsMapModel:GetItemNum(1)
    if trainItemCount < costVitaminNum then
        DialogManager.ShowToast(lang.trans("no_train_item"))
    elseif next(selectAttr) then 
        local oldCardModel = clone(self.cardDetailModel:GetCardModel())
        local pcid = oldCardModel:GetPcid()
        clr.coroutine(function()
            local response = req.cardTrainIntellect(pcid, costVitaminNum, selectAttr)
            if api.success(response) then
                local data = response.val
                self.itemsMapModel:ResetItemNum(data.cost.id, data.cost.num)
                local playerCardsMapModel = PlayerCardsMapModel.new()
                playerCardsMapModel:ResetCardData(data.card.pcid, data.card)
                local newCardModel = self.cardDetailModel:GetCardModel()
                res.PushDialog("ui.controllers.cardDetail.TrainIntellectDataShowCtrl", oldCardModel, newCardModel, costVitaminNum, data.couter)
                self.view:Close()
            end
        end)
    else
        DialogManager.ShowToast(lang.trans("train_intellect_tip"))
    end
end

return TrainIntellectCtrl
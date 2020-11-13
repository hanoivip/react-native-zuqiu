local DialogManager = require("ui.control.manager.DialogManager")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local TrainIntellectDataShowCtrl = class(BaseCtrl)
TrainIntellectDataShowCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/CardDetail/Prefabs/TrainIntellectBoard.prefab"
TrainIntellectDataShowCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function TrainIntellectDataShowCtrl:Init(oldCardModel, newCardModel, costVitaminNum, saveNum)

end

function TrainIntellectDataShowCtrl:Refresh(oldCardModel, newCardModel, costVitaminNum, saveNum)
    TrainIntellectDataShowCtrl.super.Refresh(self)
    self.view:InitView(oldCardModel, newCardModel, costVitaminNum, saveNum)
end

return TrainIntellectDataShowCtrl
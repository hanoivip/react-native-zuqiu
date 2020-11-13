local GameObjectHelper = require("ui.common.GameObjectHelper")

local CardTrainingFinishTwoCtrl = class()

function CardTrainingFinishTwoCtrl:ctor(cardTrainingMainModel, parent)
    self:Init(cardTrainingMainModel, parent)
end

function CardTrainingFinishTwoCtrl:Init(cardTrainingMainModel, parent)
    local pageObject, pageSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/CardTraining/Prefabs/FinishContent2.prefab")
    pageObject.transform:SetParent(parent, false)
    self.finishView = pageSpt
    self.finishView:InitView(cardTrainingMainModel)
end

function CardTrainingFinishTwoCtrl:ShowGameObject()
    GameObjectHelper.FastSetActive(self.finishView.gameObject, true)
    self.finishView:InitView()
end

function CardTrainingFinishTwoCtrl:HideGameObject()
    GameObjectHelper.FastSetActive(self.finishView.gameObject, false)
end

return CardTrainingFinishTwoCtrl

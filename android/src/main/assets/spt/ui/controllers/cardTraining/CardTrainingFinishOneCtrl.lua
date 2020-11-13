local GameObjectHelper = require("ui.common.GameObjectHelper")

local CardTrainingFinishOneCtrl = class()

function CardTrainingFinishOneCtrl:ctor(cardTrainingMainModel, parent)
    self:Init(cardTrainingMainModel, parent)
end

function CardTrainingFinishOneCtrl:Init(cardTrainingMainModel, parent)
    local pageObject, pageSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/CardTraining/Prefabs/FinishContent1.prefab")
    pageObject.transform:SetParent(parent, false)
    self.finishView = pageSpt
    self.finishView:InitView(cardTrainingMainModel)
end

function CardTrainingFinishOneCtrl:ShowGameObject()
    GameObjectHelper.FastSetActive(self.finishView.gameObject, true)
    self.finishView:InitView()
end

function CardTrainingFinishOneCtrl:HideGameObject()
    GameObjectHelper.FastSetActive(self.finishView.gameObject, false)
end

return CardTrainingFinishOneCtrl

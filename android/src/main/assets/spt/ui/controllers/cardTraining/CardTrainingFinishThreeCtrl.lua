local GameObjectHelper = require("ui.common.GameObjectHelper")

local CardTrainingFinishThreeCtrl = class()

function CardTrainingFinishThreeCtrl:ctor(cardTrainingMainModel, parent)
    self:Init(cardTrainingMainModel, parent)
end

function CardTrainingFinishThreeCtrl:Init(cardTrainingMainModel, parent)
    local pageObject, pageSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/CardTraining/Prefabs/FinishContent3.prefab")
    pageObject.transform:SetParent(parent, false)
    self.finishView = pageSpt
    self.finishView:InitView(cardTrainingMainModel)
end

function CardTrainingFinishThreeCtrl:ShowGameObject()
    GameObjectHelper.FastSetActive(self.finishView.gameObject, true)
    self.finishView:InitView()
end

function CardTrainingFinishThreeCtrl:HideGameObject()
    GameObjectHelper.FastSetActive(self.finishView.gameObject, false)
end

return CardTrainingFinishThreeCtrl
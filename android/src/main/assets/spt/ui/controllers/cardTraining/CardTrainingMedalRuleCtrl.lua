local BaseCtrl = require("ui.controllers.BaseCtrl")
local CardTrainingMedalRuleCtrl = class(BaseCtrl)

CardTrainingMedalRuleCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/CardTraining/Prefabs/CardTrainingMedalRuleBoard.prefab"

function CardTrainingMedalRuleCtrl:Init(data)
    self.view:InitView(data)
end

return CardTrainingMedalRuleCtrl
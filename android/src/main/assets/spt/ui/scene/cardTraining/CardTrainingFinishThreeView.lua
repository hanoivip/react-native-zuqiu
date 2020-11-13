local CardTrainingConstant = require("ui.scene.cardTraining.CardTrainingConstant")

local CardTrainingFinishThreeView = class(unity.base)

function CardTrainingFinishThreeView:ctor()
    self.tipTxt = self.___ex.tipTxt
end

function CardTrainingFinishThreeView:start()
end

function CardTrainingFinishThreeView:InitView(cardTrainingMainModel)
    --self.tipTxt.text = lang.trans("card_training_finish", self.cardTrainingMainModel:GetName())
end

return CardTrainingFinishThreeView

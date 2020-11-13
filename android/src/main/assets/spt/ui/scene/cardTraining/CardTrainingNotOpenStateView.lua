local CardTrainingNotOpenStateView = class(unity.base)

function CardTrainingNotOpenStateView:ctor()
    self.img = self.___ex.img

    self.oddPath = "Assets/CapstonesRes/Game/UI/Scene/CardTraining/Images/LevelFive1_N.png"
    self.notOddPath = "Assets/CapstonesRes/Game/UI/Scene/CardTraining/Images/LevelFive_N.png"
end

function CardTrainingNotOpenStateView:InitView(cardTrainingMainModel)
    local lvl = cardTrainingMainModel:GetCurrLevelSelected()
    if tonumber(lvl) % 2 == 0 then
        self.img.overrideSprite = res.LoadRes(self.oddPath)
    else
        self.img.overrideSprite = res.LoadRes(self.notOddPath)
    end
end

return CardTrainingNotOpenStateView
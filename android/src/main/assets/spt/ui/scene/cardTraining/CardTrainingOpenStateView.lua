local CardTrainingOpenStateView = class(unity.base)

function CardTrainingOpenStateView:ctor()
    self.img = self.___ex.img

    self.oddPath = "Assets/CapstonesRes/Game/UI/Scene/CardTraining/Images/LevelFive1_H.png"
    self.notOddPath = "Assets/CapstonesRes/Game/UI/Scene/CardTraining/Images/LevelFIve_H.png"
end

function CardTrainingOpenStateView:InitView(cardTrainingMainModel)
    local lvl = cardTrainingMainModel:GetCurrLevelSelected()
    if tonumber(lvl) % 2 == 0 then
        self.img.overrideSprite = res.LoadRes(self.oddPath)
    else
        self.img.overrideSprite = res.LoadRes(self.notOddPath)
    end
end

return CardTrainingOpenStateView
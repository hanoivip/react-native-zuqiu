local SweepResultCtrl = class()

function SweepResultCtrl:ctor(maxTimes, times, parentTrans)
    local dlg, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Training/SweepResult.prefab")
    dlg.transform:SetParent(parentTrans, false)
    self.resultView = spt
end

function SweepResultCtrl:InitView(cardModel, skillReward, score)
    self.cardModel = cardModel
    if not self.cardView then
        local cardObject = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
        self.resultView:SetCard(cardObject.transform)
        self.cardView = cardObject:GetComponent(clr.CapsUnityLuaBehav)
    end
    self.cardView:IsShowName(false)
    self.cardView:InitView(cardModel)

    self.resultView:InitView(skillReward, score, cardModel)
end

return SweepResultCtrl

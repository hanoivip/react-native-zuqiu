local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local BrainResultCtrl = class()

function BrainResultCtrl:ctor(maxTimes, times, parentTrans)
    local dlg, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Training/TrainingResult.prefab")
    dlg.transform:SetParent(parentTrans, false)
    self.resultView = spt
    self.resultView.clickPanel = function()
        Object.Destroy(dlg)
    end
end

function BrainResultCtrl:InitView(cardModel, skillReward, score)
    self.cardModel = cardModel
    if not self.cardView then
        local cardObject, cardSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
        self.resultView:SetCard(cardObject.transform)
        self.cardView = cardSpt
    end
    self.cardView:IsShowName(false)
    self.cardView:InitView(cardModel)
    self.resultView:InitView(skillReward, score, cardModel)
end

return BrainResultCtrl

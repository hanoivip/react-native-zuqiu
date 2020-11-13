local TrainCardFrameView = class(unity.base)

function TrainCardFrameView:ctor()
    self.cardParent = self.___ex.cardParent
    self.nameTxt = self.___ex.name
    self.maxPointSign = self.___ex.maxPointSign
    self.mask = self.___ex.mask
    self.btnArea = self.___ex.btnArea
    self.border = self.___ex.border
    self.checkMark = self.___ex.checkMark
end

function TrainCardFrameView:start()
    self.btnArea:regOnButtonClick(function()
        if type(self.clickCard) == "function" then
            self.clickCard()
        end
    end)
end

function TrainCardFrameView:InitView(cardModel, canJump)
    self.canJump = canJump
    self.cardModel = cardModel
    -- Card
    if not self.cardView then
        local cardObject = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
        self.cardView = cardObject:GetComponent(clr.CapsUnityLuaBehav)
        cardObject.transform:SetParent(self.cardParent.transform, false)
    end
    self.cardView:InitView(cardModel)

    self.nameTxt.text = tostring(cardModel:GetName())

    if cardModel:IsSkillLevelMax() then
        self.mask:SetActive(true)
        self.maxPointSign:SetActive(true)
    else
        self.mask:SetActive(false)
        self.maxPointSign:SetActive(false)
    end

end

function TrainCardFrameView:OnCancel()
    self.border:SetActive(false)
    self.checkMark:SetActive(false)
end

function TrainCardFrameView:OnChoose()
    self.border:SetActive(true)
    self.checkMark:SetActive(true)
end

return TrainCardFrameView

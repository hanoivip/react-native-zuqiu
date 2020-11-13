local CoachTaskCardFrameView = class(unity.base)

function CoachTaskCardFrameView:ctor()
    self.cardParent = self.___ex.cardParent
    self.nameTxt = self.___ex.name
    self.mask = self.___ex.mask
    self.btnArea = self.___ex.btnArea
    self.border = self.___ex.border
    self.checkMark = self.___ex.checkMark
end

function CoachTaskCardFrameView:start()
    self.btnArea:regOnButtonClick(function()
        if type(self.clickCard) == "function" then
            self.clickCard()
        end
    end)
end

function CoachTaskCardFrameView:SetCardResourceCache(cardResourceCache)
    self.cardResourceCache = cardResourceCache
end

function CoachTaskCardFrameView:InitView(cardModel, canJump)
    self.cardModel = cardModel
    -- Card
    if not self.cardView then
        local cardObject = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
        self.cardView = res.GetLuaScript(cardObject)
        cardObject.transform:SetParent(self.cardParent.transform, false)
    end
    self.cardView:SetCardResourceCache(self.cardResourceCache)
    self.cardView:InitView(cardModel)

    self.nameTxt.text = tostring(cardModel:GetName())
end

function CoachTaskCardFrameView:OnCancel()
    self.border:SetActive(false)
    self.checkMark:SetActive(false)
end

function CoachTaskCardFrameView:OnChoose()
    self.border:SetActive(true)
    self.checkMark:SetActive(true)
end

return CoachTaskCardFrameView

local GameObjectHelper = require("ui.common.GameObjectHelper")
local ExchangeCardFrameView = class(unity.base)

function ExchangeCardFrameView:ctor()
    self.cardParent = self.___ex.cardParent
    self.btnArea = self.___ex.btnArea
    self.checkMark = self.___ex.checkMark
    self.lockText = self.___ex.lockText
    self.lock = self.___ex.lock
    self.nameTxt = self.___ex.name
end

function ExchangeCardFrameView:start()
    self.btnArea:regOnButtonClick(function()
        if type(self.clickCard) == "function" then
            self.clickCard()
        end
    end)
end

function ExchangeCardFrameView:InitView(cardModel, cardResourceCache)
    -- Card
    self.cardModel = cardModel
    if not self.cardView then
        local cardObject = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
        self.cardView = cardObject:GetComponent(clr.CapsUnityLuaBehav)
        cardObject.transform:SetParent(self.cardParent.transform, false)
        self.cardView:SetCardResourceCache(cardResourceCache)
        self.cardView:InitView(cardModel)
        self.cardView:IsShowName(false)
    end
    self.cardView:InitView(cardModel)
    local isLock, lockData = cardModel:GetLockState()
    local desc = lockData and lockData.desc or ""
    self.lockText.text = desc
    self.nameTxt.text = tostring(cardModel:GetName())
    GameObjectHelper.FastSetActive(self.lock, isLock)
end

function ExchangeCardFrameView:OnChoose()
    GameObjectHelper.FastSetActive(self.checkMark, true)
end

function ExchangeCardFrameView:OnCancel()
    GameObjectHelper.FastSetActive(self.checkMark, false)
end

return ExchangeCardFrameView

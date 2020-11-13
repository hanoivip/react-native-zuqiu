local GameObjectHelper = require("ui.common.GameObjectHelper")
local TargetCardFrameView = class(unity.base)

function TargetCardFrameView:ctor()
    self.cardParent = self.___ex.cardParent
    self.btnArea = self.___ex.btnArea
    self.checkMark = self.___ex.checkMark
end

function TargetCardFrameView:start()
    self.btnArea:regOnButtonClick(function()
        if type(self.clickCard) == "function" then
            self.clickCard()
        end
    end)
end

function TargetCardFrameView:InitView(cardModel, cardResourceCache)
    -- Card
    self.cardModel = cardModel
    if not self.cardView then
        local cardObject = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
        self.cardView = cardObject:GetComponent(clr.CapsUnityLuaBehav)
        cardObject.transform:SetParent(self.cardParent.transform, false)
        self.cardView:SetCardResourceCache(cardResourceCache)
    end
    self.cardView:InitView(cardModel)
end

function TargetCardFrameView:OnChoose()
    GameObjectHelper.FastSetActive(self.checkMark, true)
end

function TargetCardFrameView:OnCancel()
    GameObjectHelper.FastSetActive(self.checkMark, false)
end

return TargetCardFrameView

local GameObjectHelper = require("ui.common.GameObjectHelper")
local PasterCardNodeView = class(unity.base)

function PasterCardNodeView:ctor()
    self.cardParent = self.___ex.cardParent
    self.btnArea = self.___ex.btnArea
    self.checkMark = self.___ex.checkMark
    self.nameTxt = self.___ex.name
end

function PasterCardNodeView:start()
    self.btnArea:regOnButtonClick(function()
        if type(self.clickCard) == "function" then
            self.clickCard()
        end
    end)
end

function PasterCardNodeView:InitView(cardModel)
    -- Card
    self.cardModel = cardModel
    if not self.cardView then
        local cardObject = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
        self.cardView = cardObject:GetComponent(clr.CapsUnityLuaBehav)
        cardObject.transform:SetParent(self.cardParent.transform, false)
        self.cardView:InitView(cardModel)
        self.cardView:IsShowName(false)
    end
    self.cardView:InitView(cardModel)
    self.nameTxt.text = tostring(cardModel:GetName())
end

function PasterCardNodeView:OnChoose()
    GameObjectHelper.FastSetActive(self.checkMark, true)
end

function PasterCardNodeView:OnCancel()
    GameObjectHelper.FastSetActive(self.checkMark, false)
end

return PasterCardNodeView

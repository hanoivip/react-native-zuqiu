local GameObjectHelper = require("ui.common.GameObjectHelper")
local RebornCardFrameView = class(unity.base)

function RebornCardFrameView:ctor()
    self.cardParent = self.___ex.cardParent
    self.nameTxt = self.___ex.name
    self.lessConditionSign = self.___ex.lessConditionSign
    self.txtTips = self.___ex.txtTips
    self.lockState = self.___ex.lockState
    self.mask = self.___ex.mask
    self.btnArea = self.___ex.btnArea
    self.border = self.___ex.border
    self.checkMark = self.___ex.checkMark
end

function RebornCardFrameView:start()
    self.btnArea:regOnButtonClick(function()
        if type(self.clickCard) == "function" then
            self.clickCard()
        end
    end)
end

function RebornCardFrameView:InitView(cardModel, upgradeLimit, maxAscend)
    -- Card
    self.cardModel = cardModel
    if not self.cardView then
        local cardObject = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
        self.cardView = cardObject:GetComponent(clr.CapsUnityLuaBehav)
        self.cardView:IsShowName(false)
        cardObject.transform:SetParent(self.cardParent.transform, false)
    end
    self.cardView:InitView(cardModel)

    self.nameTxt.text = tostring(cardModel:GetName())

    GameObjectHelper.FastSetActive(self.lockState, false)
    local isLock, lockData = cardModel:GetLockState()
    if isLock then 
        GameObjectHelper.FastSetActive(self.mask, true)
        GameObjectHelper.FastSetActive(self.lessConditionSign, true)
        GameObjectHelper.FastSetActive(self.lockState, true)
        self.txtTips.text = lockData.desc
    elseif cardModel:GetAscend() > maxAscend then
        self.txtTips.text = lang.trans("rebornChoose_tips5")
        GameObjectHelper.FastSetActive(self.mask, true)
        GameObjectHelper.FastSetActive(self.lessConditionSign, true)
    elseif cardModel:GetUpgrade() < upgradeLimit then
        self.txtTips.text = lang.trans("rebornChoose_tips1")
        GameObjectHelper.FastSetActive(self.mask, true)
        GameObjectHelper.FastSetActive(self.lessConditionSign, true)
    else
        GameObjectHelper.FastSetActive(self.mask, false)
        GameObjectHelper.FastSetActive(self.lessConditionSign, false)
    end
end

function RebornCardFrameView:OnChoose()
    local islock = self.cardModel:IsNotAllowSell()
    GameObjectHelper.FastSetActive(self.checkMark, not islock)
end

function RebornCardFrameView:OnCancel()
    GameObjectHelper.FastSetActive(self.checkMark, false)
end

return RebornCardFrameView

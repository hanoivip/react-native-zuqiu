local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds
local Color = UnityEngine.Color
local Vector3 = UnityEngine.Vector3
local GameObjectHelper = require("ui.common.GameObjectHelper")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local PlayerLetterInsidePlayerModel = require("ui.models.playerLetter.PlayerLetterInsidePlayerModel")
local LuaButton = require("ui.control.button.LuaButton")
local CardParentInGachaTenView = class(LuaButton)


function CardParentInGachaTenView:ctor()
    CardParentInGachaTenView.super.ctor(self)
    self.cardParent = self.___ex.cardParent
    self.rewardBoxParent = self.___ex.rewardBoxParent
    self.cardMask = self.___ex.cardMask
    self.backImg = self.___ex.backImg
    self.mainArea = self.___ex.mainArea
    self.parentAnim = self.___ex.parentAnim
    self.effect1 = self.___ex.effect1
    self.effect2 = self.___ex.effect2
    self.effect3 = self.___ex.effect3
    self.checkBox = self.___ex.checkBox
    self.selected = self.___ex.selected
    self.sold = self.___ex.sold
    self.message = self.___ex.message
    self.childGo = nil
end

function CardParentInGachaTenView:start()
    self:regOnButtonClick(function()
        self:OnCardClick()
    end)
end

function CardParentInGachaTenView:OnCardClick()
    if self.clickCard then
        self.clickCard()
    end
end

function CardParentInGachaTenView:InitView(detail, rType)
    if rType == "card" then
        self.cardModel = StaticCardModel.new(detail)
        local cardObject, cardSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
        cardObject.transform:SetParent(self.cardParent, false)
        --cardObject.transform:SetSiblingIndex(0)
        cardSpt:InitView(self.cardModel)
        local cardQuality = self.cardModel:GetCardFixQuality()
        self:SetBackImg("CardBack_Quality" .. cardQuality)
        self.childGo = cardObject
    elseif rType == "item" then
        local rbObject, rbSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Congratulations/RewardBox.prefab")
        rbObject.transform:SetParent(self.rewardBoxParent, false)
        rbObject.transform.localScale = Vector3(0.8, 0.8, 0.8)
        local rewardTable = {}
        rewardTable[rType] = {detail}
        rbSpt:InitView(rewardTable)
        rbSpt:BuildView()
        self:SetBackImg("ItemBack")
        self.childGo = rbObject
    elseif rType == "mDetail" then
        local rbObject, rbSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Congratulations/RewardBox.prefab")
        rbObject.transform:SetParent(self.rewardBoxParent, false)
        rbObject.transform.localScale = Vector3(0.8, 0.8, 0.8)
        local rewardTable = {}
        rewardTable["m"] = detail
        rbSpt:InitView(rewardTable)
        rbSpt:BuildView()
        self:SetBackImg("ItemBack")
        self.childGo = rbObject
    end
    self.mainArea:SetActive(false)
end

function CardParentInGachaTenView:PlayAnim()
    self.mainArea:SetActive(true)
    self.childGo:SetActive(false)
    self.effect1.gameObject:SetActive(true)
    self.effect1:ApplySortingOrder()
    self.parentAnim:Play("CardParentInGachaTen2")
    self.isCardTurnAround = false
end

function CardParentInGachaTenView:OnAnimEnd()
    if type(self.onAnimEndFunc) == "function" then
        self.cardParent:GetComponent(UnityEngine.CanvasGroup).alpha = 0  --Lua assist checked flag
        self.rewardBoxParent:GetComponent(UnityEngine.CanvasGroup).alpha = 0  --Lua assist checked flag
        self.onAnimEndFunc()
    end
end

function CardParentInGachaTenView:OnShowCard()
    if self.isCardTurnAround then
        EventSystem.SendEvent("GachaTenCard.OnAnimEnd")
        self.isCardTurnAround = false
    end
end

function CardParentInGachaTenView:TurnAround()
    self.parentAnim:Play("CardParentInGachaTen")
end

function CardParentInGachaTenView:OnTurnAroundStart()
    --self.effect1.gameObject:SetActive(false)
    self.childGo:SetActive(true)
    if self.cardModel then
        local cardQuality = self.cardModel:GetCardQuality()
        local flag = cardQuality < 5     
        if flag then
            self:SetCheckBox(flag)
            self:SetMessage()
        end    
    end         

    self.effect2.gameObject:SetActive(true)
    self.effect2:ApplySortingOrder()
    self.effect3.gameObject:SetActive(true)
    self.effect3:ApplySortingOrder()

end

function CardParentInGachaTenView:OnTurnAroundEnd()
    self.backImg.gameObject:SetActive(false)
    if type(self.onTurnEndCallBack) == "function" then
        self.onTurnEndCallBack()
    end
    self.isCardTurnAround = true
    --self.effect2.gameObject:SetActive(false)
end

function CardParentInGachaTenView:SetMaskAlpha(alpha)
    self.cardMask.color = Color(0, 0, 0, alpha)
end

function CardParentInGachaTenView:SetBackImg(backName)
    local imgPath = "Assets/CapstonesRes/Game/UI/Common/Images/CardQuality/"
    self.backImg.overrideSprite = res.LoadRes(imgPath .. backName .. ".png")
end

function CardParentInGachaTenView:SetSelectState(isSelected)
    self.checkBox:SetActive(true)
    self.selected:SetActive(isSelected)
end

function CardParentInGachaTenView:SetSold()
    self.sold:SetActive(true)
    self.checkBox:SetActive(false)
end

function CardParentInGachaTenView:SetCheckBox(flag)
    GameObjectHelper.FastSetActive(self.checkBox, flag)
end

function CardParentInGachaTenView:SetMessage()
    local isInLetterMessage = PlayerLetterInsidePlayerModel.new():IsBelongToLetterCard(self.cardModel:GetCid())
    GameObjectHelper.FastSetActive(self.message, isInLetterMessage)
end

function CardParentInGachaTenView:HideMessage()
    GameObjectHelper.FastSetActive(self.message, false)
end

function CardParentInGachaTenView:HideSold()
    GameObjectHelper.FastSetActive(self.sold, false)
end

return CardParentInGachaTenView

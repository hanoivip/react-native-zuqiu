local AssetFinder = require("ui.common.AssetFinder")
local CardBuilder = require("ui.common.card.CardBuilder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local CoachGuideSlotState = require("ui.scene.coach.coachGuide.CoachGuideSlotState")

local CoachGuideItemView = class(unity.base)

function CoachGuideItemView:ctor()
    self.switchBtn = self.___ex.switchBtn
    self.addBtn = self.___ex.addBtn
    self.buyBtn = self.___ex.buyBtn
    self.notOpenBtn = self.___ex.notOpenBtn
    self.cardTrans = self.___ex.cardTrans
    self.cardDetailBtn = self.___ex.cardDetailBtn
    self.canNotBuyGo = self.___ex.canNotBuyGo
    self.effectCountImg = self.___ex.effectCountImg
    self.effectCountTxt = self.___ex.effectCountTxt
end

function CoachGuideItemView:InitView(guideSlotData, coachGuideModel)
    local slotStateData = guideSlotData.slotStateData
    local state = slotStateData.state
    self:SetBtnState(state)
    if state == CoachGuideSlotState.Used then
        res.ClearChildren(self.cardTrans)
        local cardObject, cardSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
        cardObject.transform:SetParent(self.cardTrans, false)
        self.cardView = cardSpt
        self.cardView:IsShowName(false)
        local pcid = slotStateData.pcid
        local cardModel = CardBuilder.GetOwnCardModel(pcid)
        self.cardView:InitView(cardModel)
    end
    local effectAmount = guideSlotData.effectAmount
    local effectCountPicIndex = guideSlotData.effectCountPicIndex
    self.effectCountTxt.text = tostring(effectAmount)
    self.effectCountImg.sprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Coach/CoachGuide/Image/" .. effectCountPicIndex ..".png")
end

function CoachGuideItemView:SetBtnState(state)
    GameObjectHelper.FastSetActive(self.switchBtn.gameObject, state == CoachGuideSlotState.Used)
    GameObjectHelper.FastSetActive(self.addBtn.gameObject, state == CoachGuideSlotState.Unlock)
    GameObjectHelper.FastSetActive(self.buyBtn.gameObject, state == CoachGuideSlotState.Lock)
    GameObjectHelper.FastSetActive(self.notOpenBtn.gameObject, state == CoachGuideSlotState.Disable)
    GameObjectHelper.FastSetActive(self.effectCountImg.gameObject, state ~= CoachGuideSlotState.Disable)
    GameObjectHelper.FastSetActive(self.canNotBuyGo, state == CoachGuideSlotState.CanNotBuy)
end

return CoachGuideItemView

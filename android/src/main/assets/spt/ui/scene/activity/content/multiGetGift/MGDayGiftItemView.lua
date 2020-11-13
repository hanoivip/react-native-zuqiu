local CurrencyType = require("ui.models.itemList.CurrencyType")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local MGDayGiftItemView = class(unity.base)

function MGDayGiftItemView:ctor()
--------Start_Auto_Generate--------
    self.scoreTxt = self.___ex.scoreTxt
    self.itemAreaTrans = self.___ex.itemAreaTrans
    self.giftBoxImg = self.___ex.giftBoxImg
    self.giftBoxEffectGo = self.___ex.giftBoxEffectGo
    self.rewardBtn = self.___ex.rewardBtn
    self.lockGo = self.___ex.lockGo
    self.timeTipTxt = self.___ex.timeTipTxt
    self.receivedGo = self.___ex.receivedGo
--------End_Auto_Generate----------
    self.scrollAtOnce = self.___ex.scrollAtOnce
    self.anim = self.___ex.anim
    self.iconPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/MultiGetGift/Image/MG_Gift%s.png"
end

function MGDayGiftItemView:start()
    self.rewardBtn:regOnButtonClick(function()
        self:OnClickBtn()
    end)
end

function MGDayGiftItemView:InitView(giftData, multiGetGiftModel, parentScrollRect)
    self.model = multiGetGiftModel
    self.parentScrollRect = parentScrollRect
    local scoreLimit = giftData.score
    self.scoreTxt.text = tostring(scoreLimit)
    self:InitReward(giftData)
    self:SetButtonState(giftData)
end

function MGDayGiftItemView:InitReward(giftData)
    res.ClearChildren(self.itemAreaTrans)
    self.scrollAtOnce.scrollRectInParent = self.parentScrollRect
    local coinReward = giftData.coinReward
    local score = giftData.score
    giftData.contents[CurrencyType.DayGiftCoin] = coinReward
    local rewardParams = {
        parentObj = self.itemAreaTrans,
        rewardData = giftData.contents,
        isShowName = false,
        isReceive = false,
        isShowSymbol = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)
end

function MGDayGiftItemView:SetButtonState(giftData)
    self.giftData = giftData
    GameObjectHelper.FastSetActive(self.receivedGo, giftData.receive == 1)
    GameObjectHelper.FastSetActive(self.timeTipTxt.gameObject, false)
    GameObjectHelper.FastSetActive(self.rewardBtn.gameObject, false)
    GameObjectHelper.FastSetActive(self.lockGo, false)
    GameObjectHelper.FastSetActive(self.giftBoxEffectGo, false)
    self.anim.enabled = false
    local icon = giftData.icon
    if giftData.receive ~= 1 then
        local scoreLimit = giftData.score
        local nowTime = self.model:GetNowTime()
        local score = self.model:GetScore()
        if giftData.beginTime > nowTime then
            GameObjectHelper.FastSetActive(self.timeTipTxt.gameObject, true)
            local tStr = string.convertSecondToMonth(giftData.beginTime)
            self.timeTipTxt.text = lang.trans("multi_get_gift_release", tStr)
            icon = icon .. "Lock"
        else
            if score >= scoreLimit then
                GameObjectHelper.FastSetActive(self.rewardBtn.gameObject, true)
                GameObjectHelper.FastSetActive(self.giftBoxEffectGo, true)
                self.anim.enabled = true
                icon = icon .. "Unlock"
            else
                GameObjectHelper.FastSetActive(self.lockGo, true)
                icon = icon .. "TodayLock"
            end
        end
    else
        icon = icon .. "Open"
    end
    icon = string.format(self.iconPath, icon)
    self.giftBoxImg.overrideSprite = res.LoadRes(icon)
end

function MGDayGiftItemView:OnClickBtn()
    local isTimeInActivity = self.model:IsTimeInActivity()
    if not isTimeInActivity then
        return
    end
    local periodId = self.model:GetPeriodId()
    self:coroutine(function()
        local response = req.multiGetGiftReceiveGift(periodId, self.giftData.rewardID)
        if api.success(response) then
            local data = response.val
            local rewards = data.contents
            rewards[CurrencyType.DayGiftCoin] = data.coin
            CongratulationsPageCtrl.new(rewards)
            self.giftData.receive = data.receive
            self.model:RefreshGiftData(data)
            self:InitView(self.giftData,  self.model)
            EventSystem.SendEvent("MGDayGiftItemView_Receive")
        end
    end)
end

return MGDayGiftItemView

local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector3 = UnityEngine.Vector3
local Vector2 = UnityEngine.Vector2
local Timer = require('ui.common.Timer')
local GameObjectHelper = require("ui.common.GameObjectHelper")
local AssistCoachGachaView = class(unity.base, "AssistCoachGachaView")

-- 首页标签的显示个数
local MAX_TAB_COUNT = 3

function AssistCoachGachaView:ctor()
    -- 资源框
    self.infoBarDynParent = self.___ex.infoBarDynParent
    self.tabListScroll = self.___ex.tabListScroll
    self.oneBtn = self.___ex.oneBtn
    self.tenBtn = self.___ex.tenBtn
    self.exchangeBtn = self.___ex.exchangeBtn
    self.timeTxt = self.___ex.timeTxt
    self.descTxt = self.___ex.descTxt
    self.bubbleGo = self.___ex.bubbleGo
    self.discountTipTxt = self.___ex.discountTipTxt
    self.discountPriceTxt = self.___ex.discountPriceTxt
    self.orignPriceTxt = self.___ex.orignPriceTxt
    self.luckyPointTxt = self.___ex.luckyPointTxt
    self.maxPointTxt = self.___ex.maxPointTxt
    self.progressTrans = self.___ex.progressTrans
    self.tipsTxt = self.___ex.tipsTxt
    self.onePriceTxt = self.___ex.onePriceTxt
    self.tenPriceTxt = self.___ex.tenPriceTxt
    self.timeTitleGo = self.___ex.timeTitleGo
    self.arrowLeftBtn = self.___ex.arrowLeftBtn
    self.arrowRightBtn = self.___ex.arrowRightBtn
    self.iconTenTicketGo = self.___ex.iconTenTicketGo
    self.iconTenDiamindGo = self.___ex.iconTenDiamindGo
    self.iconOneTicketGo = self.___ex.iconOneTicketGo
    self.iconOneDiamondGo = self.___ex.iconOneDiamondGo

    local progressSizeDelta = self.progressTrans.sizeDelta
    self.maxRectX = progressSizeDelta.x
    self.maxRectY = progressSizeDelta.y
end

function AssistCoachGachaView:start()
    self:RegBtnEvent()
end

function AssistCoachGachaView:InitView(assistCoachGachaModel, scrollPos)
    self.assistCoachGachaModel = assistCoachGachaModel
    local gachaId = assistCoachGachaModel:GetCurrentGachaId()
    local price = assistCoachGachaModel:GetCachaOnePrice(gachaId)
    local tenPrice = assistCoachGachaModel:GetCachaTenPrice(gachaId)
    local monthTenPrice = assistCoachGachaModel:GetCachaMonthTenPrice(gachaId)
    local desc = assistCoachGachaModel:GetCachaDesc(gachaId)
    local luckyRewardDesc = assistCoachGachaModel:GetCachaLuckyRewardDesc(gachaId)
    local monthDiscountDesc = assistCoachGachaModel:GetCachaDiscountDesc(gachaId)
    local monthDiscountAmount = assistCoachGachaModel:GetCachaMonthDiscountAmount(gachaId)
    local luckyPointReward = assistCoachGachaModel:GetCachaLuckyPointReward(gachaId)
    local luckyPoint = assistCoachGachaModel:GetLuckyPoint()
    local monthBuyTimes = assistCoachGachaModel:GetMonthBuyTimes()
    local progressSize = self:GetProgress(luckyPoint, luckyPointReward)
    local isFullLucky = luckyPoint >= luckyPointReward
    local remainTime = assistCoachGachaModel:GetCachaRemainTime(gachaId)
    local monthExchangeTimes = assistCoachGachaModel:GetCachaMonthExchangeTimes()
    local consumeTypeOne = assistCoachGachaModel:GetCachaOneConsumeType(gachaId)
    local consumeTypeTen = assistCoachGachaModel:GetCachaTenConsumeType(gachaId)
    local bubbleSate = monthDiscountAmount > 0 and monthBuyTimes < monthDiscountAmount and 
            consumeTypeTen == assistCoachGachaModel.Diamond_Gacha

    if consumeTypeOne == assistCoachGachaModel.Item_Gacha then
        self.onePriceTxt.text = "X" .. 1
    else
        self.onePriceTxt.text = "X" .. price
    end

    if consumeTypeTen == assistCoachGachaModel.Item_Gacha then
        self.tenPriceTxt.text = "X" .. 1
    else
        self.tenPriceTxt.text = "X" .. tenPrice
    end

    self.discountPriceTxt.text = "X" .. monthTenPrice
    self.orignPriceTxt.text = "X" .. tenPrice
    self.descTxt.text = desc
    self.discountTipTxt.text = lang.trans("coach_gacha_discount", monthDiscountAmount)
    self.luckyPointTxt.text = tostring(luckyPoint)
    self.maxPointTxt.text = tostring(luckyPointReward)
    self.progressTrans.sizeDelta = progressSize

    if monthExchangeTimes >= 1 then
        self.tipsTxt.text = luckyRewardDesc
    else
        self.tipsTxt.text = monthDiscountDesc
    end

    GameObjectHelper.FastSetActive(self.bubbleGo, bubbleSate)
    GameObjectHelper.FastSetActive(self.iconOneTicketGo, consumeTypeOne == assistCoachGachaModel.Item_Gacha)
    GameObjectHelper.FastSetActive(self.iconOneDiamondGo, consumeTypeOne == assistCoachGachaModel.Diamond_Gacha)
    GameObjectHelper.FastSetActive(self.iconTenTicketGo, consumeTypeTen == assistCoachGachaModel.Item_Gacha)
    GameObjectHelper.FastSetActive(self.iconTenDiamindGo, consumeTypeTen == assistCoachGachaModel.Diamond_Gacha)

    self:RefreshTabScroll(scrollPos)
    self:RefreshTimeArea(remainTime)
end

function AssistCoachGachaView:RefreshTabScroll(scrollPos)
    local tabListData = self.assistCoachGachaModel:GetTabScrollData()
    self.tabListScroll:InitView(tabListData)
    self.tabListScroll:SetScrollNormalizedPosition(scrollPos or 0)
    self.tabListScroll:regOnItemIndexChanged(function(index) self:ChageArrowState(index) end)
end

function AssistCoachGachaView:RefreshTimeArea(remainTime)
    local timeState = (not remainTime) or remainTime <= 0
    GameObjectHelper.FastSetActive(self.timeTitleGo, not timeState)
    if timeState then return end
    if self.countDownTimer ~= nil then self.countDownTimer:Destroy() end
    self.countDownTimer = Timer.new(remainTime, function(time)
        if time > 0 then
            local str = string.convertSecondToTime(time)
            self.timeTxt.text =  str
        else
            EventSystem.SendEvent("AssistCoachGachaCtrl_GachaTimeOut")
        end
    end)
end

-- 首页标签箭头的隐藏和显示  最左和最右分别隐藏
function AssistCoachGachaView:ChageArrowState(scrollIndex)
    local tabListData = self.assistCoachGachaModel:GetTabScrollData()
    local leftArrowState, rightArrowState = true, true
    if #tabListData <= MAX_TAB_COUNT then
        leftArrowState = false
        rightArrowState = false
    else
        if scrollIndex == 1 then
            leftArrowState = false
        end
        if scrollIndex >= #tabListData - 2 then
            rightArrowState = false
        end
    end
    GameObjectHelper.FastSetActive(self.arrowLeftBtn.gameObject, leftArrowState)
    GameObjectHelper.FastSetActive(self.arrowRightBtn.gameObject, rightArrowState)
end

function AssistCoachGachaView:OnEnterScene()
end

function AssistCoachGachaView:OnExitScene()
    self:StopTimer()
end

function AssistCoachGachaView:RegBtnEvent()
    -- 单抽
    self.oneBtn:regOnButtonClick(function()
        if self.onOneBtnClick and type(self.onOneBtnClick) == "function" then
            self.onOneBtnClick()
        end
    end)
    -- 多抽
    self.tenBtn:regOnButtonClick(function()
        if self.onTenBtnClick and type(self.onTenBtnClick) == "function" then
            self.onTenBtnClick()
        end
    end)
    -- 礼物选择或者领取
    self.exchangeBtn:regOnButtonClick(function()
        if self.onExchangeBtnClick and type(self.onExchangeBtnClick) == "function" then
            self.onExchangeBtnClick()
        end
    end)
    -- 左箭头
    self.arrowLeftBtn:regOnButtonClick(function()
        self.tabListScroll:scrollToPreviousGroup()
        -- 暂时屏蔽 切换
        -- if self.onArrowLeftBtnClick and type(self.onArrowLeftBtnClick) == "function" then
        --     self.onArrowLeftBtnClick()
        -- end
    end)
    -- 右箭头
    self.arrowRightBtn:regOnButtonClick(function()
        self.tabListScroll:scrollToNextGroup()
        -- 暂时屏蔽 切换
        -- if self.onArrowRightBtnClick and type(self.onArrowRightBtnClick) == "function" then
        --     self.onArrowRightBtnClick()
        -- end
    end)
end

function AssistCoachGachaView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

function AssistCoachGachaView:GetProgress(nowLucky, maxLucky)
    nowLucky = tonumber(nowLucky)
    maxLucky = tonumber(maxLucky)
    local fixedX = (nowLucky / maxLucky) * self.maxRectX
    return Vector2(fixedX, self.maxRectY)
end

function AssistCoachGachaView:StopTimer()
    if self.countDownTimer ~= nil then
        self.countDownTimer:Destroy()
    end
end

return AssistCoachGachaView

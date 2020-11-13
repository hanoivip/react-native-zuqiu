local UnityEngine = clr.UnityEngine
local EventSystems = UnityEngine.EventSystems
local WaitForSeconds = UnityEngine.WaitForSeconds
local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local RewardNameHelper = require("ui.scene.itemList.RewardNameHelper")
local SimpleIntroduceModel = require("ui.models.common.SimpleIntroduceModel")
local ActivityParentView = require("ui.scene.activity.content.ActivityParentView")
local FreeShoppingCartView = class(ActivityParentView, "FreeShoppingCartView")

function FreeShoppingCartView:ctor()
--------Start_Auto_Generate--------
    self.timeRemainedTxt = self.___ex.timeRemainedTxt
    self.rewardReviewBtn = self.___ex.rewardReviewBtn
    self.helpBtn = self.___ex.helpBtn
    self.todayRewardNameTxt = self.___ex.todayRewardNameTxt
    self.todayRewardTrans = self.___ex.todayRewardTrans
    self.getDayRewardBtn = self.___ex.getDayRewardBtn
    self.getDayRewardDisableGo = self.___ex.getDayRewardDisableGo
    self.dayAreaTrans = self.___ex.dayAreaTrans
    self.chooseDay1Spt = self.___ex.chooseDay1Spt
    self.chooseDay2Spt = self.___ex.chooseDay2Spt
    self.chooseDay3Spt = self.___ex.chooseDay3Spt
    self.chooseDay4Spt = self.___ex.chooseDay4Spt
    self.chooseDay5Spt = self.___ex.chooseDay5Spt
    self.chooseDay6Spt = self.___ex.chooseDay6Spt
    self.cartImg = self.___ex.cartImg
    self.freeTimeTxt = self.___ex.freeTimeTxt
    self.getFreeRewardBtn = self.___ex.getFreeRewardBtn
    self.getFreeRewardTxt = self.___ex.getFreeRewardTxt
    self.receivedRewardGo = self.___ex.receivedRewardGo
    self.getFreeRewardRedPointGo = self.___ex.getFreeRewardRedPointGo
    self.getFreeRewardGo = self.___ex.getFreeRewardGo
    self.freeDaySelectGo = self.___ex.freeDaySelectGo
    self.cartTimeNormalTxt = self.___ex.cartTimeNormalTxt
    self.cartTimeSelectTxt = self.___ex.cartTimeSelectTxt
    self.cartAreaAnim = self.___ex.cartAreaAnim
    self.giftEffectGo = self.___ex.giftEffectGo
--------End_Auto_Generate----------
    self.chooseDaySpt = {self.chooseDay1Spt, self.chooseDay2Spt, self.chooseDay3Spt,
                         self.chooseDay4Spt, self.chooseDay5Spt, self.chooseDay6Spt}
    self.cartImgPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/FreeShoppingCart/Image/FreeShoppingCart_Car%s.png"
    self.reviewPrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/FreeShoppingCart/FreeShoppingCartRewardReview.prefab"
end

function FreeShoppingCartView:start()
    self.rewardReviewBtn:regOnButtonClick(function()
        self:RewardReviewClick()
    end)
    self.helpBtn:regOnButtonClick(function()
        self:HelpClick()
    end)
    self.getDayRewardBtn:regOnButtonClick(function()
        self:GetDayRewardClick()
    end)
    self.getFreeRewardBtn:regOnButtonClick(function()
        self:GetFreeRewardClick()
    end)
end

function FreeShoppingCartView:InitView(freeShoppingCartModel)
    self.model = freeShoppingCartModel
    self:ResetTimer()
    self:InitFreeRewardArea()
    self:InitDayChooseArea()
    GameObjectHelper.FastSetActive(self.giftEffectGo, false)
end

function FreeShoppingCartView:RefreshContent()
    self:RefreshCartImg()
end

function FreeShoppingCartView:PlayAnim()
    self.currentEventSystem = EventSystems.EventSystem.current
    self.currentEventSystem.enabled = false
    GameObjectHelper.FastSetActive(self.giftEffectGo, true)
    self:coroutine(function ()
        self.cartAreaAnim:Play("Gift")
        coroutine.yield(WaitForSeconds(2))
        self.currentEventSystem.enabled = true
        self:RefreshCartImg()
        GameObjectHelper.FastSetActive(self.giftEffectGo, false)
    end)
end

function FreeShoppingCartView:RefreshCartImg()
    local countIndex = self.model:GetChooseListCount()
    local path = string.format(self.cartImgPath, countIndex)
    self.cartImg.overrideSprite = res.LoadRes(path)
    self.cartImg:SetNativeSize()
end

function FreeShoppingCartView:InitFreeRewardArea()
    local freeReceive = self.model:GetFreeReceive()
    GameObjectHelper.FastSetActive(self.getDayRewardBtn.gameObject, not freeReceive)
    GameObjectHelper.FastSetActive(self.getDayRewardDisableGo, freeReceive)

    local freeContents = self.model:GetFreeContents()
    local rewardParams = {
        parentObj = self.todayRewardTrans,
        rewardData = freeContents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    res.ClearChildren(self.todayRewardTrans)
    RewardDataCtrl.new(rewardParams)
    local rewardName = RewardNameHelper.GetSingleContentName(freeContents)
    rewardName = string.gsub(rewardName, " ", "")
    self.todayRewardNameTxt.text = rewardName
end

function FreeShoppingCartView:InitDayChooseArea()
    local dayChooseData = self.model:GetDayChooseData()
    local groupState = self.model:GetGroupState()
    local groupChooseList = self.model:GetGroupChooseList()
    local receiveDayTime = self.model:GetReceiveDayTime()
    local isReceiveDay = self.model:IsReceiveDay()
    local receive = self.model:GetReceive()
    local isChooseReward = self.model:IsChooseReward()
    for i, v in ipairs(dayChooseData) do
        self.chooseDaySpt[i]:InitView(v)
        self.chooseDaySpt[i]:InitState(groupState[i], groupChooseList[i])
    end
    local dateTime = string.convertSecondToMonthAndDay(receiveDayTime)
    dateTime = dateTime.month .. "." .. dateTime.day
    self.freeTimeTxt.text = dateTime
    self.cartTimeNormalTxt.text = dateTime
    self.cartTimeSelectTxt.text = dateTime
    GameObjectHelper.FastSetActive(self.getFreeRewardBtn.gameObject, isReceiveDay)
    GameObjectHelper.FastSetActive(self.freeDaySelectGo.gameObject, isReceiveDay)
    GameObjectHelper.FastSetActive(self.getFreeRewardRedPointGo, not receive)
    GameObjectHelper.FastSetActive(self.getFreeRewardGo, not isReceiveDay)
    GameObjectHelper.FastSetActive(self.receivedRewardGo, receive)
    self.getFreeRewardTxt.text = lang.trans("receive")
    if isReceiveDay and not isChooseReward and not receive then
        self.getFreeRewardTxt.text = lang.trans("free_shopping_none_reward")
        GameObjectHelper.FastSetActive(self.getFreeRewardRedPointGo, false)
        GameObjectHelper.FastSetActive(self.receivedRewardGo, false)
        GameObjectHelper.FastSetActive(self.getFreeRewardGo, false)
    end
end

-- 设置倒计时
function FreeShoppingCartView:ResetTimer()
    if self.model:GetRemainTime() > 0 then
        self:RefreshTimer()
    else
        self:SetRunOutOfTimeView()
    end
end

function FreeShoppingCartView:RefreshTimer()
    local beginTime = self.model:GetBeginTime()
    local endTime = self.model:GetEndTime()
    local timeStr = lang.transstr("activityTime")
    timeStr = timeStr .. string.convertSecondToMonth(beginTime)
    timeStr = timeStr .. "--" .. string.convertSecondToMonth(endTime)
    self.timeRemainedTxt.text = timeStr
end

function FreeShoppingCartView:SetRunOutOfTimeView()
    self.timeRemainedTxt.text = lang.trans("visit_endInfo")
    if self.runOutOfTime then
        self.runOutOfTime()
    end
end

-- 奖励预览
function FreeShoppingCartView:RewardReviewClick()
    local dayChooseData = self.model:GetDayChooseData()
    local dialog, dialogcomp = res.ShowDialog(self.reviewPrefabPath, "camera", true, true)
    local script = dialogcomp.contentcomp
    script:InitView(dayChooseData)
end

-- 玩法说明
function FreeShoppingCartView:HelpClick()
    local simpleIntroduceModel = SimpleIntroduceModel.new(self.model:GetIntro())
    res.PushDialog("ui.controllers.common.SimpleIntroduceCtrl", simpleIntroduceModel)
end

-- 领取最终奖励
function FreeShoppingCartView:GetDayRewardClick()
    if self.onGetDayReward then
        self.onGetDayReward()
    end
end

-- 领取每日奖励
function FreeShoppingCartView:GetFreeRewardClick()
    if self.onGetFreeReward then
        self.onGetFreeReward()
    end
end

function FreeShoppingCartView:OnEnterScene()
    self.super.OnEnterScene(self)
end

function FreeShoppingCartView:OnExitScene()
    self.super.OnExitScene(self)
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
end

function FreeShoppingCartView:onDestroy()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
end

return FreeShoppingCartView

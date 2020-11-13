local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local MarblesExchangeModel = require("ui.models.activity.marbles.MarblesExchangeModel")
local LimitType = require("ui.scene.itemList.LimitType")
local MarblesExchangeItemView = class(unity.base)
local RewardState = MarblesExchangeModel.RewardState

function MarblesExchangeItemView:ctor()
--------Start_Auto_Generate--------
    self.exchangeTrans = self.___ex.exchangeTrans
    self.rewardTrans = self.___ex.rewardTrans
    self.exchangeBtn = self.___ex.exchangeBtn
    self.buyLimit1Txt = self.___ex.buyLimit1Txt
    self.soldOutGo = self.___ex.soldOutGo
    self.disableGo = self.___ex.disableGo
    self.buyLimit2Txt = self.___ex.buyLimit2Txt
--------End_Auto_Generate----------
    self.gradientTxt = self.___ex.gradientTxt
end

function MarblesExchangeItemView:start()
    self.exchangeBtn:regOnButtonClick(function()
        self:OnClickBtn()
    end)
end

function MarblesExchangeItemView:InitView(exchangeData, receiveCallBack)
    self.exchangeData = exchangeData
    self.clickReceive = receiveCallBack
    self.rewardID = exchangeData.rewardID
    local rewardParams = {
        parentObj = self.exchangeTrans,
        rewardData = exchangeData.fixExchangeItem,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = false,
        isShowCardReward = false,
        isShowDetail = false,
    }
    res.ClearChildren(self.exchangeTrans)
    RewardDataCtrl.new(rewardParams)

    rewardParams = {
        parentObj = self.rewardTrans,
        rewardData = exchangeData.contents,
        isShowName = true,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    res.ClearChildren(self.rewardTrans)
    RewardDataCtrl.new(rewardParams)
    local limitState = exchangeData.limitType ~= LimitType.NoLimit
    local lTxt
    local remainTimes = exchangeData.limitAmount - exchangeData.receiveTimes
    if exchangeData.limitType == LimitType.DayLimit then
        lTxt = lang.trans("marbles_limit_everyday", remainTimes, exchangeData.limitAmount)
    elseif exchangeData.limitType == LimitType.ForeverLimit then
        lTxt = lang.trans("marbles_limit_permanently", remainTimes, exchangeData.limitAmount)
    end
    self.buyLimit1Txt.text = lTxt
    self.buyLimit2Txt.text = lTxt
    GameObjectHelper.FastSetActive(self.buyLimit1Txt.gameObject, limitState)
    GameObjectHelper.FastSetActive(self.buyLimit2Txt.gameObject, limitState)
    self:SetButtonState(exchangeData.rewardState)
end

function MarblesExchangeItemView:SetButtonState(rewardState)
    GameObjectHelper.FastSetActive(self.exchangeBtn.gameObject, rewardState == RewardState.Enable)
    GameObjectHelper.FastSetActive(self.disableGo, rewardState == RewardState.Disable or rewardState == RewardState.Received)
end

function MarblesExchangeItemView:OnClickBtn()
    self.clickReceive(self.rewardID)
end

return MarblesExchangeItemView

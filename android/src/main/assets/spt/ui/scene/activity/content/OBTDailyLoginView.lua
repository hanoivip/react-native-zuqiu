local Timer = require('ui.common.Timer')
local RewardDataCtrl = require('ui.controllers.common.RewardDataCtrl')
local GameObjectHelper = require("ui.common.GameObjectHelper")
local Button = clr.UnityEngine.UI.Button
local OBTDailyLoginView = class(unity.base)

function OBTDailyLoginView:ctor()
    self.scrollObj = self.___ex.scrollObj
    self.rewardBtn = self.___ex.rewardBtn
    self.rewardTip = self.___ex.rewardTip
    self.finishIcon = self.___ex.finishIcon
    self.activityTime = self.___ex.activityTime
    self.loginTitleTxt = self.___ex.loginTitleTxt
    self.residualTimer = nil
end

function OBTDailyLoginView:start()
    self.rewardBtn:regOnButtonClick(function()
        self:OnBtnClick()
    end)
end

function OBTDailyLoginView:OnBtnClick()
    if self.clickGetReward then
        self.clickGetReward()
    end
end

function OBTDailyLoginView:InitView(obtDailyLoginModel)
    self.obtDailyLoginModel = obtDailyLoginModel
    local rewardParams = {
        parentObj = self.scrollObj,
        rewardData = obtDailyLoginModel:GetRewardContents(),
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)
    self:RefreshContent()
    self:InitGetRewardButtonState(obtDailyLoginModel)
    local desc = obtDailyLoginModel:GetDesc()
    local conditionDesc = obtDailyLoginModel:GetConditionDesc()
    if desc then
        self.loginTitleTxt.text = desc
    end
    if conditionDesc then
        self.rewardTip.text = conditionDesc
    end
end

function OBTDailyLoginView:RefreshContent()
    self.activityTime.text = lang.trans("cumulative_pay_time", string.convertSecondToMonth(self.obtDailyLoginModel:GetStartTime()), 
                        string.convertSecondToMonth(self.obtDailyLoginModel:GetEndTime()))
end

function OBTDailyLoginView:InitGetRewardButtonState(obtDailyLoginModel)
    local status = obtDailyLoginModel:GetRewardStatus()
    if status == -1 then
        self.rewardBtn:onPointEventHandle(false)
        self.rewardBtn.gameObject:GetComponent(Button).interactable = false
    elseif status == 1 then
        self:DisabledRewardButton()
    end
end

function OBTDailyLoginView:DisabledRewardButton()
    GameObjectHelper.FastSetActive(self.finishIcon, true)
    GameObjectHelper.FastSetActive(self.rewardBtn.gameObject, false)
end

function OBTDailyLoginView:OnEnterScene()
    self:RefreshContent()
end

function OBTDailyLoginView:OnExitScene()
end

function OBTDailyLoginView:OnRefresh()
end

function OBTDailyLoginView:onDestroy()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
end

return OBTDailyLoginView

local RewardDataCtrl = require('ui.controllers.common.RewardDataCtrl')
local GameObjectHelper = require("ui.common.GameObjectHelper")
local Button = clr.UnityEngine.UI.Button
local CumulativeLoginView = class(unity.base)

function CumulativeLoginView:ctor()
    self.scrollObj = self.___ex.scrollObj
    self.rewardBtn = self.___ex.rewardBtn
    self.rewardTip = self.___ex.rewardTip
    self.finishIcon = self.___ex.finishIcon
end

function CumulativeLoginView:start()
    self.rewardBtn:regOnButtonClick(function()
        self:OnBtnClick()
    end)
end

function CumulativeLoginView:OnBtnClick()
    if self.clickGetReward then
        self.clickGetReward()
    end
end

function CumulativeLoginView:InitView(cumulativeLoginModel)
    local rewardParams = {
        parentObj = self.scrollObj,
        rewardData = cumulativeLoginModel:GetRewardContents(),
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)

    self:InitRewardTipContent(cumulativeLoginModel)
    self:InitGetRewardButtonState(cumulativeLoginModel)
end

function CumulativeLoginView:InitRewardTipContent(cumulativeLoginModel)
    local value = cumulativeLoginModel:GetLoginStatus()
    if value == 1 then
        self.rewardTip.text = lang.trans("login_first")
    elseif value == 2 then
        self.rewardTip.text = lang.trans("login_second")
    elseif value == 3 then
        self.rewardTip.text = lang.trans("login_third")
    else
        GameObjectHelper.FastSetActive(self.rewardTip.gameObject, false)
    end
end

function CumulativeLoginView:InitGetRewardButtonState(cumulativeLoginModel)
    local status = cumulativeLoginModel:GetRewardStatus()
    if status == -1 then
        self.rewardBtn:onPointEventHandle(false)
        self.rewardBtn.gameObject:GetComponent(Button).interactable = false
    elseif status == 1 then
        self:DisabledRewardButton()
    end
end

function CumulativeLoginView:DisabledRewardButton()
    GameObjectHelper.FastSetActive(self.finishIcon, true)
    GameObjectHelper.FastSetActive(self.rewardBtn.gameObject, false)
end

function CumulativeLoginView:OnEnterScene()
end

function CumulativeLoginView:OnExitScene()
end

function CumulativeLoginView:OnRefresh()
end

function CumulativeLoginView:onDestroy()
end

return CumulativeLoginView

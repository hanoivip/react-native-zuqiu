local UnityEngine = clr.UnityEngine
local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local PlayerLetterConstants = require("ui.scene.playerLetter.PlayerLetterConstants")


local TimeLimitLetterItemView = class(unity.base)

function TimeLimitLetterItemView:ctor()
    self.progressBar = self.___ex.progressBar
    self.progressText = self.___ex.progressText
    self.lettername = self.___ex.lettername
    self.finishIcon = self.___ex.finishBtnDiable
    self.checkInfoBtn = self.___ex.checkInfoBtn
    self.playerAnchor = self.___ex.playerAnchor
end

function TimeLimitLetterItemView:start()
     self.checkInfoBtn:regOnButtonClick(function()
        self:OnCheckBtnClick()
    end)
end

-- state = 0 时表示可以领取奖励
function TimeLimitLetterItemView:InitRewardButtonState(state)
    if state == PlayerLetterConstants.LetterState.HAVE_AWARD then
        GameObjectHelper.FastSetActive(self.finishIcon.gameObject, true)
        GameObjectHelper.FastSetActive(self.checkInfoBtn.gameObject, false)
    else
        GameObjectHelper.FastSetActive(self.checkInfoBtn.gameObject, true)
        GameObjectHelper.FastSetActive(self.finishIcon.gameObject, false)
    end
end

function TimeLimitLetterItemView:OnCheckBtnClick()
    res.PushDialog("ui.controllers.playerLetter.ActivityPlayerLetterDetailCtrl", self.curTag, self.index, self.timeLimitedLetterModel)
end

function TimeLimitLetterItemView:InitView(timeLimitedLetterModel, index, curTag)
    local conditionSum = timeLimitedLetterModel:GetQuestConditionDecCountByIndex(index)
    local completedConditionSum = timeLimitedLetterModel:GetFinishedCountByIndex(index)
    self.timeLimitedLetterModel = timeLimitedLetterModel
    self.index = index
    self.curTag = curTag
    self.lettername.text = lang.trans("activity_playerLetterName", timeLimitedLetterModel:GetCardNameByIndex(index))
    self.progressText.text = completedConditionSum .. "/" .. conditionSum
    self.progressBar.value = completedConditionSum / conditionSum
    local rewardParams = {
        parentObj = self.playerAnchor,
        rewardData = timeLimitedLetterModel:GetCardInfoByIndex(index),
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)

    local rewardStates = timeLimitedLetterModel:GetRewardStatesByIndex(index)
    self:InitRewardButtonState(rewardStates)
end

function TimeLimitLetterItemView:UpdateSelfRewardState(letterIndex)
    if letterIndex == self.index then 
        self.timeLimitedLetterModel:SetRewardStatesByIndex(letterIndex, 1)
        self:InitRewardButtonState(1)
    end
end

return TimeLimitLetterItemView
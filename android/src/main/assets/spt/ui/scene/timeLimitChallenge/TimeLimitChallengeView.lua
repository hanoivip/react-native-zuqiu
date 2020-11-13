local UnityEngine = clr.UnityEngine
local Time = UnityEngine.Time
local UI = UnityEngine.UI
local Transition = UI.Selectable.Transition

local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local PlayerTeamsModel = require("ui.models.PlayerTeamsModel")
local Timer = require("ui.common.Timer")

local TimeLimitChallengeView = class(unity.base)

function TimeLimitChallengeView:ctor()
    self.cooldownTime = self.___ex.cooldownTime
    self.closeButton = self.___ex.closeButton
    self.scrollArea = self.___ex.scrollArea
    self.levelButtonGroup = self.___ex.levelButtonGroup
    self.powerConditionText = self.___ex.powerConditionText
    self.challengeButton = self.___ex.challengeButton
    self.challengeDisableButton = self.___ex.challengeDisableButton
    self.receiveReward = self.___ex.receiveReward
    self.finishButton = self.___ex.finishButton
    self.check = self.___ex.check
    self.leftTime = self.___ex.leftTime
    self.failButton = self.___ex.failButton
    self.challengeTimer = nil
    self.avtivityTimer = nil
    self.powerCondition = nil
    self.playerPower = nil
end

function TimeLimitChallengeView:start()
    self.closeButton:regOnButtonClick(function()
        self:Destroy()
    end)
    self.challengeButton:regOnButtonClick(function()
        if self.clickChallengeButton then
            self.clickChallengeButton()
        end
    end)
    self.receiveReward:regOnButtonClick(function()
        if self.clickReceiveButton then
            self.clickReceiveButton()
        end
    end)
    local tagsTransform = self.levelButtonGroup.transform
    for i = 1, tagsTransform.childCount do
        local btnObject = tagsTransform:GetChild(i - 1).gameObject
        btnObject:GetComponent(clr.CapsUnityLuaBehav):regOnButtonClick(function()
            self:OnTagClick(i)
        end)
    end
end

local function FormatTime(time)
    local minute = math.ceil(time / 60)
    local hour = math.floor(minute / 60)
    minute = math.floor(minute % 60)
    local day = math.floor(hour / 24)
    hour = math.floor(hour % 24)
    return tostring(day), format("%02d", hour), format("%02d", minute)
end

function TimeLimitChallengeView:InitView(timeLimitChallengeModel, currentLevel)
    self.timeLimitChallengeModel = timeLimitChallengeModel
    self.currentLevel = currentLevel
    local remainTime = timeLimitChallengeModel:GetRemainTime()
    self:UpdateLeftTime(remainTime)
    self.levelButtonGroup:selectMenuItem("level" .. currentLevel)
    self:InitRightAreaView(timeLimitChallengeModel, currentLevel)
end

function TimeLimitChallengeView:InitRightAreaView(timeLimitChallengeModel, currentLevel)
    res.ClearChildren(self.scrollArea.transform)
    self.timeLimitChallengeModel = timeLimitChallengeModel
    self.currentLevel = currentLevel
    local contents = timeLimitChallengeModel:GetContentsByLevelIndex(currentLevel)
    local rewardParams = {
        parentObj = self.scrollArea,
        rewardData = contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = false,
    }
    RewardDataCtrl.new(rewardParams)
    self.powerCondition = tonumber(timeLimitChallengeModel:GetPlayerPowerLimitByLevelIndex(currentLevel))
    self.powerConditionText.text = lang.trans("time_limit_challenge_powerLimit", self.powerCondition)
    self.state = timeLimitChallengeModel:GetStateByLevelIndex(currentLevel)
    self:InitButtons(self.state)
    local playerTeamsModel = PlayerTeamsModel.new()
    self.playerPower = tonumber(playerTeamsModel:GetTotalPower())
    self.check.gameObject:SetActive(self.playerPower >= self.powerCondition)
end

function TimeLimitChallengeView:OnTagClick(index)
    if self.clickLevelButton then
        self.clickLevelButton(index)
    end
end

function TimeLimitChallengeView:ShowRedPointAndFinishByLevel(index, state)
    local btnObject = self.levelButtonGroup.transform:GetChild(index - 1).gameObject
    local redPointObj = btnObject.transform:FindChild("RedPoint")
    local finishObj = btnObject.transform:FindChild("Finish")
    redPointObj.gameObject:SetActive(state == 0)
    finishObj.gameObject:SetActive(state == 1)
end

function TimeLimitChallengeView:InitButtons(state, cdTime)
    if state == -1 then
        local cdTime = cdTime or self.timeLimitChallengeModel:GetCooldownTime()
        if cdTime == 0 then
            self.receiveReward.gameObject:SetActive(false)
            self.finishButton.gameObject:SetActive(false)
            self.failButton.gameObject:SetActive(false)
            self:JudgeChallengeBtnInteractable()
        else
            self.challengeButton.gameObject:SetActive(false)
            self.receiveReward.gameObject:SetActive(false)
            self.finishButton.gameObject:SetActive(false)
            self.failButton.gameObject:SetActive(true)
        end
    elseif state == 0 then
        self.challengeButton.gameObject:SetActive(false)
        self.receiveReward.gameObject:SetActive(true)
        self.finishButton.gameObject:SetActive(false)
        self.failButton.gameObject:SetActive(false)
    elseif state == 1 then
        self.challengeButton.gameObject:SetActive(false)
        self.receiveReward.gameObject:SetActive(false)
        self.finishButton.gameObject:SetActive(true)
        self.failButton.gameObject:SetActive(false)
    end
end

function TimeLimitChallengeView:JudgeChallengeBtnInteractable()
    self.powerCondition = tonumber(self.timeLimitChallengeModel:GetPlayerPowerLimitByLevelIndex(self.currentLevel))
    local playerTeamsModel = PlayerTeamsModel.new()
    self.playerPower = tonumber(playerTeamsModel:GetTotalPower())
    if self.playerPower > self.powerCondition then
        self.challengeButton.gameObject:SetActive(true)
        self.challengeDisableButton:SetActive(false)
    else
        self.challengeButton.gameObject:SetActive(false)
        self.challengeDisableButton:SetActive(true)
    end
end

function TimeLimitChallengeView:ShowCooldownTime(cooldownTime)
    local cooldownTimeText = cooldownTime and string.formatTimeClock(cooldownTime, 3600)
    self.cooldownTime.text = tostring(cooldownTimeText)
    self:InitButtons(self.state, cooldownTime)
end

function TimeLimitChallengeView:UpdateCooldownTime(cooldownTime)
    if self.challengeTimer ~= nil then
        self.challengeTimer:Destroy()
    end
    self.challengeTimer = Timer.new(cooldownTime, function (time)
        self:ShowCooldownTime(time)
    end)
end

function TimeLimitChallengeView:ShowLeftTime(time)
    local day, hour, minute = FormatTime(time)
    self.leftTime.text = lang.trans("gacha_left_time", day, hour, minute)
end

function TimeLimitChallengeView:UpdateLeftTime(leftTime)
    if self.avtivityTimer ~= nil then
        self.avtivityTimer:Destroy()
    end
    self.avtivityTimer = Timer.new(leftTime, function (time)
        self:ShowLeftTime(time)
    end)
end

function TimeLimitChallengeView:Destroy()
    if type(self.closeDialog) == 'function' then
        self.closeDialog()
    end
end

function TimeLimitChallengeView:onDestroy()
    if self.challengeTimer ~= nil then
        self.challengeTimer:Destroy()
    end
    if self.avtivityTimer ~= nil then
        self.avtivityTimer:Destroy()
    end
end

return TimeLimitChallengeView

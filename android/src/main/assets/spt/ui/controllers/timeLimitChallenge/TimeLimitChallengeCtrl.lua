local BaseCtrl = require("ui.controllers.BaseCtrl")
local TimeLimitChallengeModel = require("ui.models.timeLimitChallenge.TimeLimitChallengeModel")
local MatchLoader = require("coregame.MatchLoader")
local PlayerTeamsModel = require("ui.models.PlayerTeamsModel")
local DialogManager = require("ui.control.manager.DialogManager")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")

local TimeLimitChallengeCtrl = class(BaseCtrl)
TimeLimitChallengeCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/TimeLimitChallenge/TimeLimitChallenge.prefab"

function TimeLimitChallengeCtrl:Refresh()
    TimeLimitChallengeCtrl.super.Refresh(self)
    self:RequestData()
end

function TimeLimitChallengeCtrl:RequestData()
    clr.coroutine(function()
        local response = req.activityTimeLimitChallenge()
        if api.success(response) then
            local data = response.val
            if type(data.list) ~= "table" or next(data.list) == nil then
                DialogManager.ShowToastByLang("time_limit_challenge_end")
                return false
            else
                self.timeLimitChallengeModel = TimeLimitChallengeModel.new()
                self.timeLimitChallengeModel:InitWithProtocol(data)
                self:InitRedPoint(self.timeLimitChallengeModel)
                self:InitView()
                self:UpdateCooldownTime()
            end
        end
    end)
end

function TimeLimitChallengeCtrl:InitRedPoint(timeLimitChallengeModel)
    local list = timeLimitChallengeModel:GetDataList()
    if type(list) == "table" then
        for index, data in ipairs(list) do
            self.view:ShowRedPointAndFinishByLevel(index, data.status)
        end
    end
end

function TimeLimitChallengeCtrl:InitView()
    self.currentLevelIndex = self.timeLimitChallengeModel:GetCurrentLevelIndexToShow()
    self.currentLevel = "level" .. tostring(self.currentLevelIndex)
    self.view.clickLevelButton = function(levelIndex)
        if levelIndex == self.currentLevelIndex then return end
        self.currentLevelIndex = levelIndex
        self:InitCurrentLevelView(levelIndex)
    end
    self.view.clickReceiveButton = function()
        local subId = self.timeLimitChallengeModel:GetSubIDByLevelIndex(self.currentLevelIndex)
        self:GetReward(subId)
    end
    self.view.clickChallengeButton = function()
        local powerCondition = tonumber(self.timeLimitChallengeModel:GetPlayerPowerLimitByLevelIndex(self.currentLevelIndex))
        local playerTeamsModel = PlayerTeamsModel.new()
        local playerPower = tonumber(playerTeamsModel:GetTotalPower())
        if playerPower > powerCondition then
            local subId = self.timeLimitChallengeModel:GetSubIDByLevelIndex(self.currentLevelIndex)
            self:StartTimeLimitChallengeMatch(subId)
        else
            DialogManager.ShowToastByLang("time_limit_challenge_fail")
        end
    end
    self.view:InitView(self.timeLimitChallengeModel, self.currentLevelIndex)
end

function TimeLimitChallengeCtrl:StartTimeLimitChallengeMatch(subId)
     clr.coroutine(function()
        local response = req.activityTimeLimitChallengeFight(subId)
        if api.success(response) then
            local data = response.val
            MatchLoader.startMatch(response.val)
        end
    end)
end

function TimeLimitChallengeCtrl:GetReward(subId)
    local activityType = "PowerTarget"
    clr.coroutine(function()
        local response = req.activityTimeLimitChallengeReceiveReward(activityType, subId)
        if api.success(response) then
            local data = response.val
            if next(data) then
                CongratulationsPageCtrl.new(data.contents)
                self.view:InitButtons(1)
                self.view:ShowRedPointAndFinishByLevel(self.currentLevelIndex, 1)
            end
        end
    end)
end

function TimeLimitChallengeCtrl:UpdateCooldownTime()
    local cooldownTime = self.timeLimitChallengeModel:GetCooldownTime()
    self.view:UpdateCooldownTime(cooldownTime)
end

function TimeLimitChallengeCtrl:InitCurrentLevelView(levelIndex)
    self.view:InitRightAreaView(self.timeLimitChallengeModel, levelIndex)
end

return TimeLimitChallengeCtrl
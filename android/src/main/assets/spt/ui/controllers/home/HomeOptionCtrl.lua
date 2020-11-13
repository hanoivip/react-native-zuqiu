local UnityEngine = clr.UnityEngine
local TimeLimitChallengeCtrl = require("ui.controllers.timeLimitChallenge.TimeLimitChallengeCtrl")
local UnlockModel = require("ui.models.common.UnlockModel")
local HomeMenuHelper = require("ui.scene.home.HomeMenuHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local UISoundManager = require("ui.control.manager.UISoundManager")
local HomeOptionCtrl = class()

local function ShowCommonDialog()
    DialogManager.ShowAlertPopByLang("tips", "functionNotOpen", function() end)
end

function HomeOptionCtrl:ctor(view, viewParent, parentScript)
    self.optionView = view
    self.parentScript = parentScript
    self.optionView.OnOptionClick = function(selector, key) self:OnOptionClick(key) end
    self:InitButtonEvent()
end

function HomeOptionCtrl:InitView(playerInfoModel, isQuestLimitOpen)
    if playerInfoModel then
        self.playerInfoModel = playerInfoModel
    end
    if isQuestLimitOpen ~= nil then
        self.optionView:SetTimeLimitChallengeState(isQuestLimitOpen)
    end
    self.unlockModel = UnlockModel.new()
    self.optionView:InitView(self.playerInfoModel, self.unlockModel, HomeMenuHelper.ContentOpenOption)
end

function HomeOptionCtrl:InitButtonEvent()
    self.optionView.btnStroy:regOnButtonClick(function()
        self:OnStoryClick()
    end)
    self.optionView.btnLeague:regOnButtonClick(function()
        self:OnLeagueClick()
    end)
    self.optionView.btnTrain:regOnButtonClick(function()
        self:OnTrainClick()
    end)
    self.optionView.btnGuild:regOnButtonClick(function()
        self:OnGuildClick()
    end)
    self.optionView.timeLimitChallenge:regOnButtonClick(function()
        self:OnTimeLimitChallengeClick()
    end)
end

function HomeOptionCtrl:GetOptionState(option)
    local level = self.playerInfoModel:GetLevel()
    self.unlockModel:SetCurrentLevel(level)
    local isOpen = self.unlockModel:GetStateById(option.Id)
    if not isOpen then
        UISoundManager.play('limitSound', 1)
        local optionData = self.unlockModel:GetTipsById(option.Id)
        local msg = lang.trans("unlock_tips", optionData["function"], optionData["playerLevel"])
        DialogManager.ShowToast(msg)
    end
    return isOpen
end

function HomeOptionCtrl:OnStoryClick()
    EventSystem.SendEvent("HomeScene_MoveOut", function()
        clr.coroutine(function()
            unity.waitForEndOfFrame()
            res.PushSceneImmediate("ui.controllers.quest.QuestPageCtrl")
        end)
    end)
end

function HomeOptionCtrl:OnLeagueClick()
    local isOpen = self:GetOptionState(HomeMenuHelper.ContentOpenOption.League)
    if isOpen then
        EventSystem.SendEvent("HomeScene_MoveOut", function()
            require("ui.controllers.league.LeagueCtrl").new()
        end)
    end
end

function HomeOptionCtrl:OnTrainClick()
    local isOpen = self:GetOptionState(HomeMenuHelper.ContentOpenOption.Train)
    if isOpen then
        EventSystem.SendEvent("HomeScene_MoveOut", function()
            res.PushScene("ui.controllers.training.TrainCtrl")
        end)
    end
end

function HomeOptionCtrl:OnGuildClick()
    ShowCommonDialog()
end

function HomeOptionCtrl:OnTimeLimitChallengeClick()
    res.PushDialog("ui.controllers.timeLimitChallenge.TimeLimitChallengeCtrl")
end

function HomeOptionCtrl:OnEffectEnter()
    self.optionView:OnEffectPosSet(true)
end

function HomeOptionCtrl:OnEffectLeave()
    self.optionView:OnEffectPosSet()
end

function HomeOptionCtrl:Refresh(isQuestLimitOpen)
    self:InitView(nil, isQuestLimitOpen)
end

return HomeOptionCtrl
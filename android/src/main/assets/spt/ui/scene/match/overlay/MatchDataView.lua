local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector3 = UnityEngine.Vector3
local Screen = UnityEngine.Screen
local Tweening = clr.DG.Tweening
local DOTween = Tweening.DOTween
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions

local CommonConstants = require("ui.common.CommonConstants")
local MatchInfoModel = require("ui.models.MatchInfoModel")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local UISoundManager = require("ui.control.manager.UISoundManager")
local AudioManager = require("unity.audio")

local MatchDataView = class(unity.base)

function MatchDataView:ctor()
    self.shootDataView = self.___ex.shootDataView
    self.stealDataView = self.___ex.stealDataView
    self.interceptDataView = self.___ex.interceptDataView
    self.foulDataView = self.___ex.foulDataView
    self.cornerDataView = self.___ex.cornerDataView
    self.passDataView = self.___ex.passDataView
    self.controlDataView = self.___ex.controlDataView
    self.homeTeamNameText = self.___ex.homeTeamNameText
    self.visitTeamNameText = self.___ex.visitTeamNameText
    self.scoreText = self.___ex.scoreText
    self.homeTeamImage = self.___ex.homeTeamImage
    self.visitTeamImage = self.___ex.visitTeamImage
    self.confirmTxt = self.___ex.confirmTxt
    -- 动画管理器
    self.animator = self.___ex.animator
    -- 继续按钮
    self.continueBtn = self.___ex.continueBtn
    -- 回放按钮
    self.highlightsBtn = self.___ex.highlightsBtn
    -- 胜利物体集合
    self.winObjs = self.___ex.winObjs
    -- 失败和平局物体集合
    self.failObjs = self.___ex.failObjs
    -- 退出按钮
    self.exitBtn = self.___ex.exitBtn

    -- 比赛关卡是否有特殊通关条件
    self.matchStageIsSpecial = false
    -- 比赛结果，1:胜利，0:平局，-1:失败
    self.matchScoreText = nil
    self.resultStatus = nil
    self.matchInfoModel = nil
end

function MatchDataView:InitView(resultStatus, matchStageIsSpecial)
    self.resultStatus = resultStatus
    self.matchStageIsSpecial = matchStageIsSpecial
    self.matchInfoModel = MatchInfoModel.GetInstance()
end

function MatchDataView:start()
    self.matchResultAudioPlayer = AudioManager.GetPlayer("matchResult")
    local playerTeamData = self.matchInfoModel:GetPlayerTeamData()
    local opponentTeamData = self.matchInfoModel:GetOpponentTeamData()
    self:SetGameStatisticalData(playerTeamData, opponentTeamData)
    self:RegisterEvent()
    self:BindAll()
    self:PlayMoveInAnim()
end

function MatchDataView:BindAll()
    self.matchResultAudioPlayer.PlayAudio("Assets/CapstonesRes/Game/Audio/UI/Match/scorePanel.wav", 1)
    self.continueBtn:regOnButtonClick(function ()
        self:PlayMatchResultMoveOutAnim()
    end)
    self.highlightsBtn:regOnButtonClick(function()
        EventSystem.SendEvent("SettlementPageView.ShowHighlightsView")
    end)
    if self.exitBtn then
        self.exitBtn:regOnButtonClick(function()
            local matchResultData = cache.getMatchResult()
            matchResultData.skipLoseGuide = true
            self:PlayMatchResultMoveOutAnim()
        end)
    end
end

--- 注册事件
function MatchDataView:RegisterEvent()
    EventSystem.AddEvent("MatchDataView.PlayMoveOutAnim", self, self.PlayMoveOutAnim)
end

--- 移除事件
function MatchDataView:RemoveEvent()
    EventSystem.RemoveEvent("MatchDataView.PlayMoveOutAnim", self, self.PlayMoveOutAnim)
end

function MatchDataView:SetGameStatisticalData(playerTeamData, opponentTeamData)
    local playerStats = playerTeamData.stats
    local opponentStats = opponentTeamData.stats
    self:SetTeamName(self.homeTeamNameText, playerTeamData.teamName)
    self:SetTeamName(self.visitTeamNameText, opponentTeamData.teamName)
    TeamLogoCtrl.BuildTeamLogo(self.homeTeamImage, playerTeamData.logo)
    TeamLogoCtrl.BuildTeamLogo(self.visitTeamImage, opponentTeamData.logo)

    if self.matchInfoModel:IsGiveUpMatch() then
        self.scoreText.text = "-"
        self.shootDataView:InitView("-", "-")
        self.stealDataView:InitView("-", "-")
        self.interceptDataView:InitView("-", "-")
        self.foulDataView:InitView("-", "-")
        self.cornerDataView:InitView("-", "-")
        self.passDataView:InitView("-", "-")
        self.controlDataView:InitView("-", "-")
    else
        if playerStats.penaltyScore and opponentStats.penaltyScore and (opponentStats.penaltyScore > 0 or playerStats.penaltyScore > 0) then
            -- 有点球大战的比分
            self.scoreText.text = playerStats.score .. "/" .. playerStats.penaltyScore .. " - " .. opponentStats.score .. "/" .. opponentStats.penaltyScore
        else
            -- 没有点球大战的比分
            self.scoreText.text = playerStats.score .. " - " .. opponentStats.score
        end
        self.shootDataView:InitView(tostring(playerStats.shootTimes) .. "[" .. tostring(playerStats.shootOnGoalTimes) .. "]", tostring(opponentStats.shootTimes) .. "[" .. tostring(opponentStats.shootOnGoalTimes) .. "]")
        self.stealDataView:InitView(tostring(playerStats.stealTimes), tostring(opponentStats.stealTimes))
        self.interceptDataView:InitView(tostring(playerStats.interceptTimes), tostring(opponentStats.interceptTimes))
        self.foulDataView:InitView(tostring(playerStats.foulTimes) .. "[" .. tostring(playerStats.offsideTimes or 0) .. "]", tostring(opponentStats.foulTimes) .. "[" .. tostring(opponentStats.offsideTimes or 0) .. "]")
        self.cornerDataView:InitView(tostring(playerStats.cornerTimes), tostring(opponentStats.cornerTimes))
        self.passDataView:InitView(tostring(playerStats.passing) .. "%", tostring(opponentStats.passing) .. "%")
        self.controlDataView:InitView(tostring(playerStats.possession) .. "%", tostring(opponentStats.possession) .. "%")
    end
    self.matchScoreText = self.scoreText.text
    local isWinAndDraw = self.resultStatus >= 0
    for k, obj in pairs(self.winObjs) do
        obj:SetActive(isWinAndDraw)
    end
    for k, obj in pairs(self.failObjs) do
        obj:SetActive(not isWinAndDraw)
    end
    if not isWinAndDraw and self.confirmTxt then
        self.confirmTxt.text = lang.trans("be_strong_title")
    end

    if self.exitBtn then
        self.exitBtn.gameObject:SetActive(not isWinAndDraw)
    end
end

function MatchDataView:GetMatchScoreText()
    return self.matchScoreText
end

function MatchDataView:SetTeamName(teamNameText, teamName)
    teamNameText.text = teamName
    local teamNameLen = string.len(teamName)
    if teamNameLen > 20 then
        local scaleX = 20 / teamNameLen
        teamNameText.transform.localScale = Vector3(scaleX < 0.8 and 0.8 or scaleX, 1, 1)
    end
end

function MatchDataView:PlayMoveInAnim()
    self.animator:Play("Base Layer.MoveIn", 0)
    self.animator.enabled = false
    self.animator:Update(0)
    local mySequence = DOTween.Sequence()
    TweenSettingsExtensions.AppendInterval(mySequence, 0)
    TweenSettingsExtensions.AppendCallback(mySequence, function ()
        self.animator.enabled = true
    end)
end

function MatchDataView:PlayMoveOutAnim()
    self.animator:Play("Base Layer.MoveOut", 0)
end

function MatchDataView:PlayMatchResultMoveOutAnim()
    EventSystem.SendEvent("MatchResultView.PlayMoveOutAnim")
end

function MatchDataView:OnAnimEnd(animMoveType)
    if animMoveType == CommonConstants.UIAnimMoveType.MOVE_OUT then
        local mySequence = DOTween.Sequence()
        TweenSettingsExtensions.AppendInterval(mySequence, 0.1)
        TweenSettingsExtensions.AppendCallback(mySequence, function ()
            EventSystem.SendEvent("SettlementPageView.ExitScene")
        end)
    end
end

function MatchDataView:onDestroy()
    Object.Destroy(self.matchResultAudioPlayer.gameObject)
    self:RemoveEvent()
end

return MatchDataView

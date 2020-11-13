local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local Screen = UnityEngine.Screen
local Tweening = clr.DG.Tweening
local DOTween = Tweening.DOTween
local Tweener = Tweening.Tweener
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease

local MatchInfoModel = require("ui.models.MatchInfoModel")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local CommonConstants = require("ui.common.CommonConstants")
local UISoundManager = require("ui.control.manager.UISoundManager")
local Timer = require("ui.common.Timer")

local MiddleMatchNotify = class(unity.base)

function MiddleMatchNotify:ctor()
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
    self.continueBtn = self.___ex.continueBtn
    -- 动画管理器
    self.animator = self.___ex.animator
    -- 提示信息
    self.tipText = self.___ex.tipText
    self.tipTimer = nil
end

function MiddleMatchNotify:start()
    EventSystem.SendEvent("FightMenuManager.CloseViewsOnCertainTime")
    local matchInfoModel = MatchInfoModel.GetInstance()
    local playerTeamData = matchInfoModel:GetPlayerTeamData()
    local opponentTeamData = matchInfoModel:GetOpponentTeamData()
    self:SetGameStatisticalData(playerTeamData, opponentTeamData)
    self:BindAll()
    self:PlayMoveInAnim()
end

function MiddleMatchNotify:BindAll()
    self.continueBtn:regOnButtonClick(function ()
        self:DestroyTimer()
        self:PlayMoveOutAnim()
    end)
end

function MiddleMatchNotify:SetGameStatisticalData(playerTeamData, opponentTeamData)
    local playerStats = playerTeamData.stats
    local opponentStats = opponentTeamData.stats
    self:SetTeamName(self.homeTeamNameText, tostring(playerTeamData.teamName))
    self:SetTeamName(self.visitTeamNameText, tostring(opponentTeamData.teamName))
    TeamLogoCtrl.BuildTeamLogo(self.homeTeamImage, playerTeamData.logo)
    TeamLogoCtrl.BuildTeamLogo(self.visitTeamImage, opponentTeamData.logo)
    self.scoreText.text = playerStats.score .. " - " .. opponentStats.score

    self.shootDataView:InitView(tostring(playerStats.shootTimes) .. "[" .. playerStats.shootOnGoalTimes .. "]", tostring(opponentStats.shootTimes) .. "[" .. opponentStats.shootOnGoalTimes .. "]")
    self.stealDataView:InitView(tostring(playerStats.stealTimes), tostring(opponentStats.stealTimes))
    self.interceptDataView:InitView(tostring(playerStats.interceptTimes), tostring(opponentStats.interceptTimes))
    self.foulDataView:InitView(tostring(playerStats.foulTimes) .. "[" .. tostring(playerStats.offsideTimes or 0) .. "]", tostring(opponentStats.foulTimes) .. "[" .. tostring(opponentStats.offsideTimes or 0) .. "]")
    self.cornerDataView:InitView(tostring(playerStats.cornerTimes), tostring(opponentStats.cornerTimes))
    self.passDataView:InitView(tostring(playerStats.passing) .. "%", tostring(opponentStats.passing) .. "%")
    self.controlDataView:InitView(tostring(playerStats.possession) .. "%", tostring(opponentStats.possession) .. "%")
end

function MiddleMatchNotify:SetTeamName(teamNameText, teamName)
    teamNameText.text = teamName
    local teamNameLen = string.len(teamName)
    if teamNameLen > 20 then
        local scaleX = 20 / teamNameLen
        teamNameText.transform.localScale = Vector3(scaleX < 0.8 and 0.8 or scaleX, 1, 1)
    end
end

function MiddleMatchNotify:PlayOn()
    if type(self.closeDialog) == 'function' then
        ___deadBallTimeManager:TryToSkipDeadBallTimeScene(0)
        GameHubWrap.SetSkipSignal(0)
        self.closeDialog()
        if TimeLineWrap.IsInFastForward() and ___matchUI.isFastForwardBeforeHalfTime == true then
            TimeLineWrap.StartFastForward(___matchUI.timeScaleMultipleBeforeHalfTime)
        end
        EventSystem.SendEvent("Match_OnSecondHalfStart")
    end
end

function MiddleMatchNotify:PlayMoveInAnim()
    self.animator:Play("Base Layer.MoveIn", 0)
    UISoundManager.play('Match/matchHalfPanel', 1)
end

function MiddleMatchNotify:PlayMoveOutAnim()
    self.animator:Play("Base Layer.MoveOut", 0)
end

function MiddleMatchNotify:EndAnimation()
    self:PlayOn()
end

function MiddleMatchNotify:OnAnimEnd(animMoveType)
    if animMoveType == CommonConstants.UIAnimMoveType.MOVE_IN then
        self:PlayCountdown()
    elseif animMoveType == CommonConstants.UIAnimMoveType.MOVE_OUT then
        self:EndAnimation()
    end
end

--- 播放5秒倒计时
function MiddleMatchNotify:PlayCountdown()
    self:DestroyTimer()
    self.tipTimer = Timer.new(5, function (lastSeconds)
        lastSeconds = math.round(lastSeconds)
        self.tipText.text = lang.trans("match_halfTimeCountdown", lastSeconds)
        if lastSeconds == 0 then
            self:DestroyTimer()
            self:PlayMoveOutAnim()
        end
    end)
end

--- 销毁计时器
function MiddleMatchNotify:DestroyTimer()
    if self.tipTimer ~= nil then
        self.tipTimer:Destroy()
        self.tipTimer = nil
    end
end

return MiddleMatchNotify

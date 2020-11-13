local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds
local Tweening = clr.DG.Tweening
local DOTween = Tweening.DOTween
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions

local MatchConstants = require("ui.scene.match.MatchConstants")
local CommonConstants = require("ui.common.CommonConstants")
local MatchInfoModel = require("ui.models.MatchInfoModel")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")

local GoalInfo = class(unity.base)

function GoalInfo:ctor()
    self.rectTrans = self.___ex.rectTrans
    self.nameTxt = self.___ex.name
    self.number = self.___ex.number
    self.time = self.___ex.time
    self.homeTeamLogoBox = self.___ex.homeTeamLogoBox
    self.homeTeamLogo = self.___ex.homeTeamLogo
    self.awayTeamLogoBox = self.___ex.awayTeamLogoBox
    self.awayTeamLogo = self.___ex.awayTeamLogo
    self.event = self.___ex.event
    -- 动画管理器
    self.animator = self.___ex.animator
    self.stayTime = 1
    self.goalPlayers = {}
    self.isInitedData = false
    self.playerTeamData = nil
    self.opponentTeamData = nil
end

function GoalInfo:awake()
    if self.isInitedData == false then
        self:InitData()
    end
end

function GoalInfo:InitData()
    self.isInitedData = true
    local matchInfoModel = MatchInfoModel.GetInstance()
    self.playerTeamData = matchInfoModel:GetPlayerTeamData()
    self.opponentTeamData = matchInfoModel:GetOpponentTeamData()
    TeamLogoCtrl.BuildTeamLogo(self.homeTeamLogo, self.playerTeamData.logo)
    TeamLogoCtrl.BuildTeamLogo(self.awayTeamLogo, self.opponentTeamData.logo)
end

function GoalInfo:Init(isPlayer, athleteData, score, useTime)
    if self.isInitedData == false then
        self:InitData()
    end
    if isPlayer then
        self.homeTeamLogoBox:SetActive(true)
        self.awayTeamLogoBox:SetActive(false)
    else
        self.homeTeamLogoBox:SetActive(false)
        self.awayTeamLogoBox:SetActive(true)
    end
    self.number.text = tostring(athleteData.number)
    self.nameTxt.text = athleteData.name
    self.time.text = tostring(useTime)

    if self.goalPlayers[athleteData.id] == nil then
        self.goalPlayers[athleteData.id] = 1
    else
        self.goalPlayers[athleteData.id] = self.goalPlayers[athleteData.id] + 1
        if self.goalPlayers[athleteData.id] > #MatchConstants.GoalEvent then
            self.goalPlayers[athleteData.id] = #MatchConstants.GoalEvent
        end
    end
    self.event.text = MatchConstants.GoalEvent[self.goalPlayers[athleteData.id]]
end

function GoalInfo:PlayMoveInAnim()
    self.gameObject:SetActive(true)
    self.animator:Play("Base Layer.MoveIn", 0)
    self.animator.enabled = false
    self.animator:Update(0)
    local mySequence = DOTween.Sequence()
    TweenSettingsExtensions.AppendInterval(mySequence, 0)
    TweenSettingsExtensions.AppendCallback(mySequence, function ()
        self.animator.enabled = true
    end)
end

function GoalInfo:PlayMoveOutAnim()
    coroutine.yield(WaitForSeconds(self.stayTime))
    self.animator:Play("Base Layer.MoveOut", 0)
end

function GoalInfo:EndAnimation()
    self.gameObject:SetActive(false)
end

function GoalInfo:OnAnimEnd(animMoveType)
    if animMoveType == CommonConstants.UIAnimMoveType.MOVE_IN then
        self:coroutine(function ()
            self:PlayMoveOutAnim()
        end)
    elseif animMoveType == CommonConstants.UIAnimMoveType.MOVE_OUT then
        self:EndAnimation()
    end
end

return GoalInfo

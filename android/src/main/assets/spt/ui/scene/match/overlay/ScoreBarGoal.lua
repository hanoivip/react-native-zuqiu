local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds

local MatchInfoModel = require("ui.models.MatchInfoModel")
local CommonConstants = require("ui.common.CommonConstants")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")

local ScoreBarGoal = class(unity.base)

function ScoreBarGoal:ctor()
    self.rectTrans = self.___ex.rectTrans
    self.homeTeamName = self.___ex.homeTeamName
    self.homeTeamLogo = self.___ex.homeTeamLogo
    self.awayTeamName = self.___ex.awayTeamName
    self.awayTeamLogo = self.___ex.awayTeamLogo
    self.scoreText = self.___ex.scoreText
    self.stayTime = 1
    -- 动画管理器
    self.animator = self.___ex.animator
end

function ScoreBarGoal:start()
    local matchInfoModel = MatchInfoModel.GetInstance()
    local playerTeamData = matchInfoModel:GetPlayerTeamData()
    local opponentTeamData = matchInfoModel:GetOpponentTeamData()
    self:BuildTeam(self.homeTeamLogo, self.homeTeamName, playerTeamData)
    self:BuildTeam(self.awayTeamLogo, self.awayTeamName, opponentTeamData)
end

function ScoreBarGoal:BuildTeam(teamLogo, teamName, teamData)
    TeamLogoCtrl.BuildTeamLogo(teamLogo, teamData.logo)
    teamName.text = teamData.teamName
end

function ScoreBarGoal:Init(score)
    self.scoreText.text = score
    if self.gameObject.activeSelf then
        self:PlayMoveInAnim()
    end
end

function ScoreBarGoal:PlayMoveInAnim()
    self.animator:Play("Base Layer.MoveIn", 0)
end

function ScoreBarGoal:PlayMoveOutAnim()
    coroutine.yield(WaitForSeconds(self.stayTime))
    self.animator:Play("Base Layer.MoveOut", 0)
end

function ScoreBarGoal:EndAnimation()
    self.gameObject:SetActive(false)
    EventSystem.SendEvent("FightMenuManager.ShowPlayerGoalPanel")
end

function ScoreBarGoal:OnAnimEnd(animMoveType)
    if animMoveType == CommonConstants.UIAnimMoveType.MOVE_IN then
        self:coroutine(function ()
            self:PlayMoveOutAnim()
        end)
    elseif animMoveType == CommonConstants.UIAnimMoveType.MOVE_OUT then
        self:EndAnimation()
    end
end

return ScoreBarGoal

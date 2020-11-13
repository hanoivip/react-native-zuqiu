local Tweening = clr.DG.Tweening
local DOTweenComponent = Tweening.Core.DOTweenComponent

local MatchInfoModel = require("ui.models.MatchInfoModel")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local CommonConstants = require("ui.common.CommonConstants")
local UISoundManager = require("ui.control.manager.UISoundManager")

local TeamMatchPanel = class(unity.base)

function TeamMatchPanel:ctor()
    self.canvasGroup = self.___ex.canvasGroup
    -- 主队
    self.homeTeam = self.___ex.homeTeam
    -- 客队
    self.awayTeam = self.___ex.awayTeam
    -- 主队logo
    self.homeTeamLogo = self.___ex.homeTeamLogo
    -- 客队logo
    self.awayTeamLogo = self.___ex.awayTeamLogo
    -- 主队名称
    self.homeTeamName = self.___ex.homeTeamName
    -- 客队名称
    self.awayTeamName = self.___ex.awayTeamName
    -- 对抗图标
    self.vsIcon = self.___ex.vsIcon
    self.animator = self.___ex.animator
    self.matchInfoModel = nil
end

function TeamMatchPanel:awake()
    DOTweenComponent.DestroyInstance()
    DOTweenComponent.Create()
end

function TeamMatchPanel:start()
    self:BuildPage()
end

function TeamMatchPanel:BuildPage()
    self.matchInfoModel = MatchInfoModel.GetInstance()
    local playerTeamData = self.matchInfoModel:GetPlayerTeamData()
    local opponentTeamData = self.matchInfoModel:GetOpponentTeamData()
    self:BuildTeam(self.homeTeamLogo, self.homeTeamName, playerTeamData)
    self:BuildTeam(self.awayTeamLogo, self.awayTeamName, opponentTeamData)
end

function TeamMatchPanel:BuildTeam(teamLogo, teamName, teamData)
    TeamLogoCtrl.BuildTeamLogo(teamLogo, teamData.logo)
    teamName.text = teamData.teamName
end

function TeamMatchPanel:SetAnimActive(isActive)
    self.homeTeam.gameObject:SetActive(isActive)
    self.awayTeam.gameObject:SetActive(isActive)
    self.vsIcon.gameObject:SetActive(isActive)
    self.animator.enabled = isActive
end

function TeamMatchPanel:OnAnimStart()
    UISoundManager.play('Match/showTeamLogo', 1)
end

function TeamMatchPanel:OnAnimEnd(animMoveType)
    if animMoveType == CommonConstants.UIAnimMoveType.MOVE_IN then
        if self.matchInfoModel:IsDemoMatch() then
            EventSystem.SendEvent("PreMatchManager.StartMatch")
        else
            self:SwitchToTeamInfoPanel()
        end
    end
end

function TeamMatchPanel:SwitchToTeamInfoPanel()
    EventSystem.SendEvent("PreMatchManager.SwitchToHomeTeamInfoPanel")
end

return TeamMatchPanel

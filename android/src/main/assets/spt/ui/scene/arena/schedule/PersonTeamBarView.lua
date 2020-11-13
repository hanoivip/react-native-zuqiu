local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PersonTeamBarView = class(unity.base)

function PersonTeamBarView:ctor()
    self.homeLogo = self.___ex.homeLogo
    self.homeName = self.___ex.homeName
    self.visitName = self.___ex.visitName
    self.visitLogo = self.___ex.visitLogo
    self.score = self.___ex.score
    self.video = self.___ex.video
    self.video:regOnButtonClick(function()
        self:OnClickVideo()
    end)
end

function PersonTeamBarView:OnClickVideo()
    if self.clickVideo then 
        self.clickVideo(self.vid, self.version)
    end
end

function PersonTeamBarView:InitView(teamData, arenaScheduleTeamModel, playerId)
    local home = teamData.h == 1 and teamData.t1 or teamData.t2
    local visit = teamData.h == 1 and teamData.t2 or teamData.t1
    local homeScore = home.goal
    local visitScore = visit.goal
    local homeId = home.id
    local visitId = visit.id
    local homePenaltyScore = home.goal_penalty
    local visitPenaltyScore = visit.goal_penalty
    local homeLogoData = arenaScheduleTeamModel:GetPlayerLogo(homeId)
    TeamLogoCtrl.BuildTeamLogo(self.homeLogo, homeLogoData)
    local visitLogoData = arenaScheduleTeamModel:GetPlayerLogo(visitId)
    TeamLogoCtrl.BuildTeamLogo(self.visitLogo, visitLogoData)
    self.homeName.text = arenaScheduleTeamModel:GetPlayerName(homeId)
    self.visitName.text = arenaScheduleTeamModel:GetPlayerName(visitId)

    self.homeName.color = homeId == playerId and Color.yellow or Color.white
    self.visitName.color = visitId == playerId and Color.yellow or Color.white

    self.vid = teamData.vid
    self.version = teamData.version
    if homeScore and visitScore then
        local scoreStr = homeScore .. ":" .. visitScore
        if homePenaltyScore and visitPenaltyScore and not(homePenaltyScore == 0 and visitPenaltyScore == 0) then
            local penaltyScore = lang.transstr("penalty_score", homePenaltyScore, visitPenaltyScore)
            scoreStr = scoreStr .. "\n" .. "<color=#ffd200><size=16>" .. penaltyScore .. "</size></color>"
        end
        self.score.text = scoreStr
    else
        self.score.text = "VS"
    end
    GameObjectHelper.FastSetActive(self.video.gameObject, tobool(self.vid))
end

return PersonTeamBarView
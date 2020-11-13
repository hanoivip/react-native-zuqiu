local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Color = UnityEngine.Color

local LeagueConstants = require("ui.scene.league.LeagueConstants")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")

local LeagueScheduleRoundBarView = class(unity.base)

function LeagueScheduleRoundBarView:ctor()
    -- 比分
    self.score = self.___ex.score
    -- 主场队伍logo
    self.homeTeamLogo = self.___ex.homeTeamLogo
    -- 客场队伍logo
    self.awayTeamLogo = self.___ex.awayTeamLogo
    -- 主场队伍名称
    self.homeTeamName = self.___ex.homeTeamName
    -- 客场队伍名称
    self.awayTeamName = self.___ex.awayTeamName
    -- 背景图
    self.mImg = self.___ex.mImg
    -- 索引
    self.index = nil
    -- model
    self.leagueInfoModel = nil
    -- 队伍比赛数据
    self.teamMatchData = nil
    -- 玩家ID
    self.playerID = nil
end

function LeagueScheduleRoundBarView:InitView(index, leagueInfoModel, teamMatchData)
    self.index = index
    self.leagueInfoModel = leagueInfoModel
    self.teamMatchData = teamMatchData
    self.playerID = self.leagueInfoModel:GetPlayerID()
    
    self:BuildPage()
end

function LeagueScheduleRoundBarView:start()
end

function LeagueScheduleRoundBarView:BuildPage()
    local homeTeamData = nil
    local awayTeamData = nil

    if self.teamMatchData.h == LeagueConstants.HomeAndAway.HOME then
        homeTeamData = self.teamMatchData["t1"]
        awayTeamData = self.teamMatchData["t2"]
    else
        homeTeamData = self.teamMatchData["t2"]
        awayTeamData = self.teamMatchData["t1"]
    end

    self:BuildTeam(homeTeamData, self.homeTeamLogo, self.homeTeamName)
    self:BuildTeam(awayTeamData, self.awayTeamLogo, self.awayTeamName)

    if homeTeamData.goal ~= nil and awayTeamData.goal ~= nil then
        self.score.text = homeTeamData.goal .. ":" .. awayTeamData.goal
    else
        self.score.text = "VS"
    end

    if self.index % 2 == 1 then
        self.mImg.color = Color(0.02, 0.055, 0.086, 0.7)
    else
        self.mImg.color = Color(0, 0, 0, 0)
    end
end

--- 构建队伍
function LeagueScheduleRoundBarView:BuildTeam(teamData, teamLogo, teamName)
    TeamLogoCtrl.BuildTeamLogo(teamLogo, teamData.logo)
    teamName.text = teamData.name
    if self.playerID == teamData.id then
        teamName.color = Color(0.98, 0.92, 0.275, 1)
    else
        teamName.color = Color(0.992, 0.965, 0.855)
    end    
end

return LeagueScheduleRoundBarView
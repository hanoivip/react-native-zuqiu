local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3

local EventSystem = require("EventSystem")
local LeagueConstants = require("ui.scene.league.LeagueConstants")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerTeamsModel = require("ui.models.PlayerTeamsModel")
local LeagueNextMatchPageView = class(unity.base)

function LeagueNextMatchPageView:ctor()
    -- 比赛轮数
    self.turnNum = self.___ex.turnNum
    -- 主场队伍logo
    self.homeTeamLogo = self.___ex.homeTeamLogo
    -- 客场队伍logo
    self.awayTeamLogo = self.___ex.awayTeamLogo
    -- 主场队伍名称
    self.homeTeamName = self.___ex.homeTeamName
    -- 客场队伍名称
    self.awayTeamName = self.___ex.awayTeamName
    -- 主场排名
    self.homeRank = self.___ex.homeRank
    -- 客场排名
    self.awayRank = self.___ex.awayRank
    -- 主场积分
    self.homeScore = self.___ex.homeScore
    -- 对方积分
    self.awayScore = self.___ex.awayScore
    -- 主场战力pos
    self.homePowerParent = self.___ex.homePowerParent
    -- 客场战力pos
    self.awayPowerParent = self.___ex.awayPowerParent
    -- 主场team logo background
    self.homeTeamBg = self.___ex.homeTeamBg
    -- 客场team logo background
    self.awayTeamBg = self.___ex.awayTeamBg
    -- 主场(玩家)team logo background self
    self.homeTeamSelfBg = self.___ex.homeTeamSelfBg
    -- 客场(玩家)team logo background self
    self.awayTeamSelfBg = self.___ex.awayTeamSelfBg
    -- model
    self.leagueInfoModel = nil
    -- 联赛等级
    self.leagueLevel = nil
    -- 赛程轮次
    self.scheduleRound = nil
    -- 联赛基本信息
    self.baseInfo = nil
    -- 当前赛程
    self.nowSchedule = nil
    -- 玩家ID
    self.playerID = nil
end

function LeagueNextMatchPageView:InitView(leagueInfoModel, onBuildPowerCallback)
    self.leagueInfoModel = leagueInfoModel
    self.leagueLevel = self.leagueInfoModel:GetLeagueLevel()
    self.baseInfo = self.leagueInfoModel:GetBaseInfo()
    self.scheduleRound = self.leagueInfoModel:GetScheduleRound()
    self.nowSchedule = self.leagueInfoModel:GetNowSchedule()
    self.onBuildPowerCallback = onBuildPowerCallback
    self.playerID = self.leagueInfoModel:GetPlayerID()
    
    self:BuildPage()
end

function LeagueNextMatchPageView:start()
end

function LeagueNextMatchPageView:BuildPage()
    self.turnNum.text = lang.trans("league_leagueLevelAndTurn", self.leagueLevel, self.scheduleRound)
    local homeTeamData = nil
    local awayTeamData = nil

    if self.nowSchedule.h == LeagueConstants.HomeAndAway.HOME then
        homeTeamData = self.nowSchedule["t1"]
        awayTeamData = self.nowSchedule["t2"]
    else
        homeTeamData = self.nowSchedule["t2"]
        awayTeamData = self.nowSchedule["t1"]
    end
    if homeTeamData then
        self.homePowerCtrl = self:BuildTeam(homeTeamData, self.homeTeamLogo, self.homeTeamName, self.homeRank, self.homeScore, self.homePowerCtrl, self.homePowerParent, self.homeTeamBg, self.homeTeamSelfBg)
    end
    if awayTeamData then
        self.awayPowerCtrl = self:BuildTeam(awayTeamData, self.awayTeamLogo, self.awayTeamName, self.awayRank, self.awayScore, self.awayPowerCtrl, self.awayPowerParent, self.awayTeamBg, self.awayTeamSelfBg)
    end
end

--- 构建队伍
function LeagueNextMatchPageView:BuildTeam(teamData, teamLogo, teamName, teamRank, teamScore, powerCtrl, powerParent, teamBg, teamBgSelf)
    TeamLogoCtrl.BuildTeamLogo(teamLogo, teamData.logo)
    GameObjectHelper.FastSetActive(teamBg, self.playerID ~= teamData.id)
    GameObjectHelper.FastSetActive(teamBgSelf, self.playerID == teamData.id)
    teamName.text = teamData.name
    if teamData.rank and teamData.score then
        teamRank.text = lang.trans("league_rank", teamData.rank)
        teamScore.text = lang.trans("league_score", teamData.score)
    else
        teamRank.text = ""
        teamScore.text = ""
    end

    if self.playerID == teamData.id then
        local playerTeamsModel = PlayerTeamsModel.new()
        local playerPower = tonumber(playerTeamsModel:GetTotalPower())
        return self.onBuildPowerCallback(self, powerCtrl, powerParent, playerPower)
    else
        return self.onBuildPowerCallback(self, powerCtrl, powerParent, teamData.power)
    end
end

return LeagueNextMatchPageView
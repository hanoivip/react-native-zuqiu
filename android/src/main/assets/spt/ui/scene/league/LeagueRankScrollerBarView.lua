local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Color = UnityEngine.Color

local LeagueConstants = require("ui.scene.league.LeagueConstants")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local LeagueRankScrollerBarView = class(unity.base)

function LeagueRankScrollerBarView:ctor()
    -- 排名
    self.rankNum = self.___ex.rankNum
    -- logo
    self.teamLogo = self.___ex.teamLogo
    -- 队伍名称
    self.teamName = self.___ex.teamName
    -- 背景图
    self.bgColor = self.___ex.bgColor
    -- 前三名排行组
    self.rankGroup = self.___ex.rankGroup
    -- 高亮
    self.lightGroup = self.___ex.lightGroup
    -- 索引
    self.index = nil
    -- 队伍数据
    self.teamData = nil
end

function LeagueRankScrollerBarView:InitView(index, teamData, playerID)
    self.index = index
    self.teamData = teamData
    self.playerID = playerID
    
    self:BuildPage()
end

function LeagueRankScrollerBarView:start()
end

function LeagueRankScrollerBarView:BuildPage()
    local rankNum = self.teamData.pos + 1
    self.rankNum.text = lang.trans("league_rank", rankNum)
    self.teamName.text = self.teamData.name
    if self.playerID == self.teamData.id then
        self.teamName.color = Color(0.98, 0.92, 0.275, 1)
        GameObjectHelper.FastSetActive(self.lightGroup, true)
    else
        self.teamName.color = Color.white
        GameObjectHelper.FastSetActive(self.lightGroup, false)
    end
    TeamLogoCtrl.BuildTeamLogo(self.teamLogo, self.teamData.logo)
    self.bgColor.gameObject:SetActive(self.index % 2 == 0)
    GameObjectHelper.FastSetActive(self.rankNum.gameObject, true)
    if rankNum <= 3 then
        for i = 1, 3 do
            if self.rankGroup["num" .. i] then
                GameObjectHelper.FastSetActive(self.rankGroup["num" .. i], i == rankNum)
            end
        end
        GameObjectHelper.FastSetActive(self.rankNum.gameObject, false)
    end
end

return LeagueRankScrollerBarView

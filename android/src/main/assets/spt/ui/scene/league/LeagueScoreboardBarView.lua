local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Color = UnityEngine.Color

local EventSystem = require("EventSystem")
local LeagueConstants = require("ui.scene.league.LeagueConstants")

local LeagueScoreboardBarView = class(unity.base)

function LeagueScoreboardBarView:ctor()
    -- 背景图
    self.mImg = self.___ex.mImg
    -- 排名
    self.rank = self.___ex.rank
    -- 名称
    self.nameTxt = self.___ex.name
    -- 场数
    self.turn = self.___ex.turn
    -- 胜利场数
    self.win = self.___ex.win
    -- 失败场数
    self.lose = self.___ex.lose
    -- 平局场数
    self.draw = self.___ex.draw
    -- 进球
    self.goal = self.___ex.goal
    -- 失球
    self.loseBall = self.___ex.loseBall
    -- 净胜球
    self.gd = self.___ex.gd
    -- 积分
    self.score = self.___ex.score
    -- 索引
    self.index = nil
    -- 队伍数据
    self.teamData = nil
    -- model
    self.leagueInfoModel = nil
    -- 玩家ID
    self.playerID = nil
end

function LeagueScoreboardBarView:InitView(index, teamData, leagueInfoModel)
    self.index = index
    self.teamData = teamData
    self.leagueInfoModel = leagueInfoModel
    self.playerID = self.leagueInfoModel:GetPlayerID()
    
    self:BuildPage()
end

function LeagueScoreboardBarView:start()
end

function LeagueScoreboardBarView:BuildPage()
    if self.index % 2 == 1 then
        self.mImg.color = Color(0.02, 0.055, 0.086, 0.7)
    else
        self.mImg.color = Color(0, 0, 0, 0)
    end

    if self.teamData ~= nil then
        self.rank.text = tostring(self.teamData.pos + 1)
        self.nameTxt.text = tostring(self.teamData.name)
        self.turn.text = tostring(self.teamData.win + self.teamData.fail + self.teamData.equal)
        self.win.text = tostring(self.teamData.win)
        self.lose.text = tostring(self.teamData.fail)
        self.draw.text = tostring(self.teamData.equal)
        self.goal.text = tostring(self.teamData.goal)
        self.loseBall.text = tostring(self.teamData.lose)
        self.gd.text = tostring(self.teamData.pwin)
        self.score.text = tostring(self.teamData.score)
        if self.playerID == self.teamData.id then
            self.nameTxt.color = Color(0.98, 0.92, 0.275, 1)
        else
            self.nameTxt.color = Color(0.992, 0.965, 0.855)
        end
    else
        self.rank.text = ""
        self.nameTxt.text = ""
        self.turn.text = ""
        self.win.text = ""
        self.lose.text = ""
        self.draw.text = ""
        self.goal.text = ""
        self.loseBall.text = ""
        self.gd.text = ""
        self.score.text = ""
    end
end

return LeagueScoreboardBarView
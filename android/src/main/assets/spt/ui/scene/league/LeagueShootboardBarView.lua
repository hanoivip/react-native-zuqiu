local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Color = UnityEngine.Color

local EventSystem = require("EventSystem")
local LeagueConstants = require("ui.scene.league.LeagueConstants")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local LeagueShootboardBarView = class(unity.base)

function LeagueShootboardBarView:ctor()
    -- 背景图
    self.mImg = self.___ex.mImg
    -- 排名
    self.rank = self.___ex.rank
    -- 名称
    self.nameTxt = self.___ex.name
    -- 球队名
    self.teamName = self.___ex.teamName
    -- 进球
    self.goal = self.___ex.goal
    -- 索引
    self.index = nil
    -- 球员数据
    self.playerData = nil
    -- 队伍model
    self.leagueInfoModel = nil
    -- 玩家ID
    self.playerID = nil
end

function LeagueShootboardBarView:InitView(index, playerData, leagueInfoModel)
    self.index = index
    self.playerData = playerData
    self.leagueInfoModel = leagueInfoModel
    self.playerID = self.leagueInfoModel:GetPlayerID()
    
    self:BuildPage()
end

function LeagueShootboardBarView:start()
end

function LeagueShootboardBarView:BuildPage()
    if self.index % 2 == 1 then
        self.mImg.color = Color(0.02, 0.055, 0.086, 0.7)
    else
        self.mImg.color = Color(0, 0, 0, 0)
    end

    if self.playerData ~= nil then
        self.rank.text = tostring(self.index)
        self.nameTxt.text = tostring(self.playerData.name)
        self.teamName.text = tostring(self.playerData.teamName)
        self.goal.text = tostring(self.playerData.goal)
        if self.playerID == self.playerData.tid then
            self.teamName.color = Color(0.98, 0.92, 0.275, 1)
        else
            self.teamName.color = Color(0.992, 0.965, 0.855)
        end
    else
        self.rank.text = ""
        self.nameTxt.text = ""
        self.teamName.text = ""
        self.goal.text = ""
        self.teamName.color = Color(0.992, 0.965, 0.855)
    end
end

return LeagueShootboardBarView
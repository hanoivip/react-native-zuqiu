local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local UI = UnityEngine.UI
local Text = UI.Text

local EventSystem = require("EventSystem")
local LeagueConstants = require("ui.scene.league.LeagueConstants")

local LeagueScoreboardView = class(unity.base)

function LeagueScoreboardView:ctor()
    -- 列表区域
    self.listArea = self.___ex.listArea
    -- model
    self.leagueInfoModel = nil
    -- 积分榜数据
    self.scoreboardData = nil
end

function LeagueScoreboardView:InitView(leagueInfoModel)
    self.leagueInfoModel = leagueInfoModel
    self.scoreboardData = self.leagueInfoModel:GetScoreboard()
    self:InitListArea()
end

--- 初始化列表区域
function LeagueScoreboardView:InitListArea()
    local barObj = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/League/LeagueScoreboardBar.prefab")
    for i = 1, LeagueConstants.TeamSum do
        local go = Object.Instantiate(barObj)
        go.transform:SetParent(self.listArea, false)
        local teamData = self.scoreboardData[i]
        local goScript = go:GetComponent(clr.CapsUnityLuaBehav)
        goScript:InitView(i, teamData, self.leagueInfoModel)
    end
end

return LeagueScoreboardView

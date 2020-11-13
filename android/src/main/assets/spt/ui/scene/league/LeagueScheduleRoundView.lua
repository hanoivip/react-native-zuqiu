local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local UI = UnityEngine.UI
local Text = UI.Text

local EventSystem = require("EventSystem")
local LeagueConstants = require("ui.scene.league.LeagueConstants")

local LeagueScheduleRoundView = class(unity.base)

function LeagueScheduleRoundView:ctor()
    -- 标题
    self.title = self.___ex.title
    -- 队伍比赛信息框
    self.teamMatchContent = self.___ex.teamMatchContent
    -- model
    self.leagueInfoModel = nil
    -- 比赛轮次
    self.roundIndex = nil
    -- 比赛轮次数据
    self.roundData = nil
end

function LeagueScheduleRoundView:InitView(leagueInfoModel, roundIndex, roundData)
    self.leagueInfoModel = leagueInfoModel
    self.roundIndex = roundIndex
    self.roundData = roundData
    
    self:BuildPage()
end

function LeagueScheduleRoundView:start()
end

function LeagueScheduleRoundView:BuildPage()
    self.title.text = lang.trans("league_leagueRound_2", self.roundIndex)

    for i = 1, self.teamMatchContent.childCount do
        Object.Destroy(self.teamMatchContent:GetChild(i - 1).gameObject)
    end

    local barObj = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/League/LeagueScheduleRoundBar.prefab")
    for i, teamMatchData in ipairs(self.roundData) do
        local go = Object.Instantiate(barObj)
        go.transform:SetParent(self.teamMatchContent, false)
        local goScript = go:GetComponent(clr.CapsUnityLuaBehav)
        goScript:InitView(i, self.leagueInfoModel, teamMatchData)
    end
end

return LeagueScheduleRoundView
